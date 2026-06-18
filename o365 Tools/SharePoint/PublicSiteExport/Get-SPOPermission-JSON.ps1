$tenantURL = "https://dougsbaker-admin.sharepoint.com/"
$AdminUpn = "doug@dougsbaker.com" #Admin Account that is being used. 
$OutputFolder = "C:\Output Files" # Output folder path

# Check if the SharePoint Online module is installed
if (-not (Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable)) {
    Write-Error "The Microsoft.Online.SharePoint.PowerShell module is not installed. Please install it using:
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force"
    return
}


# Check PowerShell major version
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7 or later
    Import-Module -Name Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell
    Write-Host "Running in PowerShell 7+, using -UseWindowsPowerShell"
}
else {
    # Windows PowerShell (5.1 or earlier)
    Import-Module -Name Microsoft.Online.SharePoint.PowerShell
    Write-Host "Running in Windows PowerShell"
}



try {
    Get-SPOSite -Limit 1
    $isConnected = $true
}
catch {
    $isConnected = $false
}

y
# Connect if not already connected
if (-not $isConnected) {
    try {
        Connect-SPOService -Url $tenantURL
        Write-Host "Connected to SharePoint Online successfully."
    }
    catch {
        Write-Error "Failed to connect to SharePoint Online: $($_.Exception.Message)"
        return
    }
}
else {
    Write-Host "Already connected to SharePoint Online."
}


# -------------------- Helpers --------------------

$ErrorActionPreference = 'Stop'
$AdminSiteBuild = "_layouts/15/online/AdminHome.aspx#/siteManagement/:/SiteDetails/"


function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)] [ScriptBlock]$Script,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 2
    )
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try { return & $Script } catch {
            if ($i -eq $MaxAttempts) { throw }
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Ensure-ReadableUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$SiteUrl,
        [Parameter(Mandatory)] [string]$AdminUpn,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 3
    )

    # Initialize result object
    $result = [pscustomobject]@{
        SiteUrl  = $SiteUrl
        AdminUpn = $AdminUpn
        Elevated = $false   # Was elevation required?
        Users    = $null    # The user list returned
        Error    = $null    # Capture any terminal error
    }

    try {
        # Try reading without elevation
        $result.Users = Get-SPOUser -Limit All -Site $SiteUrl -ErrorAction Stop
        return $result
    }
    catch {
        Write-Host "Access denied on $SiteUrl. Temporarily granting SCA to $AdminUpn..." -ForegroundColor Yellow
        $elevated = $false
        $result.Elevated = $true

        try {
            # Elevate permissions
            Set-SPOUser -Site $SiteUrl -LoginName $AdminUpn -IsSiteCollectionAdmin $true -ErrorAction Stop
            $elevated = $true
            $result.Elevated = $true

            Start-Sleep -Seconds 2

            # Retry after elevation
            $result.Users = Invoke-WithRetry -Script { 
                Get-SPOUser -Limit All -Site $SiteUrl -ErrorAction Stop 
            } -MaxAttempts $MaxRetries -DelaySeconds $DelaySeconds
        }
        catch {
            $result.Error = $_
            throw
        }
        finally {
            if ($elevated) {
                try {
                    Set-SPOUser -Site $SiteUrl -LoginName $AdminUpn -IsSiteCollectionAdmin $false -ErrorAction SilentlyContinue
                    Write-Host "Removed temporary SCA on $SiteUrl." -ForegroundColor DarkGray
                }
                catch {
                    Write-Warning "Could not remove temporary SCA on $SiteUrl : $($_.Exception.Message)"
                }
            }
        }

        return $result
    }
}


function Normalize-ToStringArray {
    param($Value)
    if (-not $Value) { return @() }
    if ($Value -is [string]) { return @($Value) }
    if ($Value -is [System.Collections.IEnumerable]) { return @($Value | ForEach-Object { "$_" }) }
    return @("$Value")
}

function Get-LoginNameString {
    param($u)
    $ln = $null
    if ($u.PSObject.Properties.Name -contains 'LoginName') { $ln = $u.LoginName }
    elseif ($u.PSObject.Properties.Name -contains 'UserPrincipalName') { $ln = $u.UserPrincipalName }
    elseif ($u.PSObject.Properties.Name -contains 'Email') { $ln = $u.Email }
    if ($ln -is [bool]) { return $ln.ToString().ToLower() }
    return [string]$ln
}


function Get-PrincipalType {
    param($u)

    # Check if property 'IsGroup' exists
    if ($u.PSObject.Properties.Match('IsGroup')) {
        return ($(if ($u.IsGroup) { 'Group' } else { 'User' }))
    }

    # Check if Email property exists and has value
    $hasEmail = $u.PSObject.Properties.Match('Email') -and $u.Email
    if (-not $hasEmail -and ("$($u.LoginName)" -notmatch '@')) {
        return 'Group'
    }

    return 'User'
}


# AAD/M365 directory group (keep these as members when they’re assigned to SP groups)
function Is-DirectoryGroup {
    param($u)
    $ln = (Get-LoginNameString $u)
    return ($ln -match '\|membership\|' -or $ln -match 'federateddirectory' -or $ln -match '@')
}

function Get-SpecialGroupTag {
    param([string]$DisplayName, [string]$LoginName)
    if ($DisplayName -match 'Everyone except external users') { return 'EveryoneExceptExternal' }
    if ($LoginName -match 'rolemanager\|spo-grid-all-users') { return 'Everyone' }
    $null
}

# -------------------- Sites --------------------

if (-not $Sites) {
    Write-Host "Fetching sites..." -ForegroundColor Cyan
    $Sites = Get-SPOSite -Limit ALL
}

if ($UrlIncludes -and $UrlIncludes.Count -gt 0) {
    $lowerNeedles = $UrlIncludes | ForEach-Object { $_.ToLowerInvariant() }
    $Sites = $Sites | Where-Object {
        $u = $_.Url.ToString().ToLowerInvariant()
        (($lowerNeedles | Where-Object { $u -like "*$_*" }).Count -gt 0)
    }
}

# -------------------- Audit --------------------

$all = New-Object System.Collections.Generic.List[object]
$index = 0
$total = ($Sites | Measure-Object).Count
if ($total -eq 0) { Write-Host "No sites to process." -ForegroundColor Yellow }

foreach ($site in $Sites) {
    $index++
    Write-Progress -Activity "Auditing SharePoint permissions" -Status "$index / $total : $($site.Url)" -PercentComplete (([double]$index / [math]::Max(1, $total)) * 100)

    $users = @()
    try {
        $result = Ensure-ReadableUsers -SiteUrl $site.Url -AdminUpn $AdminUpn -MaxRetries $MaxRetries -DelaySeconds $DelaySeconds
        $users = $result.Users
    }
    catch {
        Write-Warning "Failed to read users for $($site.Url): $($_.Exception.Message)"
        $all.Add([pscustomobject]@{
                Name        = $site.Title
                Url         = $site.Url
                UserCount   = 0
                Components  = @{ Principals = @() }
                Permissions = @()
                Summary     = @{ GroupCount = 0; PrincipalCount = 0; GroupsWithEveryone = 0 }
                Notes       = "FailedToReadUsers"
            })
        continue
    }

    # ---- Build principals and group->members (safe mapping) ----
    $principals = New-Object System.Collections.Generic.List[object]
    $groupToMembers = @{}
    $userCount = 0
    $groupCount = 0
    $EUGroupinUse = $false
    $EEEUGroupinUse = $false
    $EditSiteUrl = $tenantURL + $AdminSiteBuild + $site.SiteId 
    $SiteUsers = New-Object System.Collections.Generic.List[object]
    $SiteGroups = New-Object System.Collections.Generic.List[object]
    foreach ($u in $users) {
               
        $ptype = Get-PrincipalType $u
        $login = Get-LoginNameString $u
        $groups = Normalize-ToStringArray $u.Groups
        
        if ($ptype -eq 'User'  ) {
            $userCount++ 
           
            $principalUser = [pscustomobject]@{
                DisplayName = $u.DisplayName
                LoginName   = $login
                Email       = $u.Email
                UserType    = $ptype            # 'User' | 'Group'
                Groups      = $groups
                SiteAdmin   = $u.IsSiteAdmin       
            }
            
            $SiteUsers.Add($principalUser)
        } 

        if ($ptype -eq 'group' -and $groups -ne $nul) {
                      
            $principalGroup = [pscustomobject]@{
                DisplayName = $u.DisplayName
                LoginName   = $login
                Email       = $u.Email
                UserType    = $ptype            # 'User' | 'Group'
                Groups      = $groups
                SiteAdmin   = $u.IsSiteAdmin       
            }
            if ($u.DisplayName -eq "Everyone except external users") {
                $EEEUGroupinUse = $true
            }
            if ($u.DisplayName -eq "Everyone") {
                $EUGroupinUse = $true
            }
            $SiteGroups.Add($principalgroup)
        }
        

       
    }


    $record = [pscustomobject]@{
        Name         = $site.Title
        Url          = $site.Url
        UserCount    = $userCount
        groupCount   = $groupCount
        SiteUsers    = $SiteUsers
        SiteGroups   = $SiteGroups
        EditSiteUrl  = $EditSiteUrl
        EUGroupUsed  = $EUGroupinUse
        EEUGroupUSed = $EEEUGroupinUse
        
    }

    $all.Add($record)
}

# -------------------- Output JSON --------------------

$json = $all | ConvertTo-Json -Depth 12

# Check if the directory is accessible
if (Test-Path -Path $OutputFolder -PathType Container) {
    Write-Host "Output directory is accessible."
}
else {
    Write-Host "Output directory is not accessible." -ForegroundColor Red
}
$Filename = $OutputFolder + "\file.Json"
$json | Out-File -FilePath $Filename  -force

# Prompt to open the CSV file
$OpenFile = Read-Host "json file generated at $Filename . Would you like to open it? (Y/N)"
if ($OpenFile -eq 'Y' -or $OpenFile -eq 'y') {
    Invoke-Item -Path $Filename 
}