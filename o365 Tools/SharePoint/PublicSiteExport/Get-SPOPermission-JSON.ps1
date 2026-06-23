#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    Get SharePoint Online site permissions and export to JSON.

.DESCRIPTION
    This script is provided free of charge and open source under the MIT License.
    You are free to use, modify, and distribute it for any purpose.

    THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    USE AT YOUR OWN RISK. Always test in a non-production environment before
    running against a live tenant.

.NOTES
    To analyze the exported JSON output, upload the file to:
        https://purview.expert/tools/spo-permissions
    Access code: SPOAnalyze
#>

[CmdletBinding()]
param(
    [string]   $TenantUrl = "https://dougsbaker-admin.sharepoint.com/",
    [string]   $AdminUpn = "doug@dougsbaker.com",
    [string]   $OutputFolder = "C:\Output Files",
    [string[]] $UrlIncludes = @(),
    [int]      $MaxRetries = 3,
    [int]      $DelaySeconds = 2
)

$ErrorActionPreference = 'Stop'

$b = "4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKVlyAgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICDilojilojilZfilojilojilZfilojilojilojilojilojilojilojilZfilojilojilZcgICAg4paI4paI4pWXICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWXICDilojilojilZfilojilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlwrilojilojilZTilZDilZDilojilojilZfilojilojilZEgICDilojilojilZHilojilojilZTilZDilZDilojilojilZfilojilojilZEgICDilojilojilZHilojilojilZHilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZEgICAg4paI4paI4pWRICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4pWa4paI4paI4pWX4paI4paI4pWU4pWd4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWdCuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4pWRIOKWiOKVlyDilojilojilZEgICDilojilojilojilojilojilZcgICDilZrilojilojilojilZTilZ0g4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZTilZ0gICDilojilojilZEgICAK4paI4paI4pWU4pWQ4pWQ4pWQ4pWdIOKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KVmuKWiOKWiOKVlyDilojilojilZTilZ3ilojilojilZHilojilojilZTilZDilZDilZ0gIOKWiOKWiOKVkeKWiOKWiOKWiOKVl+KWiOKWiOKVkSAgIOKWiOKWiOKVlOKVkOKVkOKVnSAgIOKWiOKWiOKVlOKWiOKWiOKVlyDilojilojilZTilZDilZDilZDilZ0g4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZTilZDilZDilojilojilZcgICDilojilojilZEgICAK4paI4paI4pWRICAgICDilZrilojilojilojilojilojilojilZTilZ3ilojilojilZEgIOKWiOKWiOKVkSDilZrilojilojilojilojilZTilZ0g4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWX4pWa4paI4paI4paI4pWU4paI4paI4paI4pWU4pWd4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWU4pWdIOKWiOKWiOKVl+KWiOKWiOKVkSAgICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojilojilZEgICDilojilojilZEgICAK4pWa4pWQ4pWdICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVnSAg4pWa4pWQ4pWdICDilZrilZDilZDilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnSDilZrilZDilZDilZ3ilZrilZDilZDilZ0g4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZ0gICAgIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdICAg4pWa4pWQ4pWdICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg"
$decodedBytes = [System.Convert]::FromBase64String($b)
$decodedString = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
Write-Host $decodedString -ForegroundColor Cyan

$sep = '-' * 110
Write-Host $sep -ForegroundColor DarkCyan
Write-Host "  SharePoint Online Permissions Audit" -ForegroundColor White
Write-Host "  Complimentary tool by purview.expert  |  MIT License  |  Use at your own risk" -ForegroundColor DarkGray
Write-Host $sep -ForegroundColor DarkCyan
Write-Host "  Tenant   : $TenantUrl" -ForegroundColor Gray
Write-Host "  Admin    : $AdminUpn"  -ForegroundColor Gray
Write-Host "  Output   : $OutputFolder" -ForegroundColor Gray
if ($UrlIncludes.Count -gt 0) {
    Write-Host "  Filter   : $($UrlIncludes -join ', ')" -ForegroundColor Gray
}
Write-Host "  Started  : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host $sep -ForegroundColor DarkCyan
Write-Host ""

# Validate output folder before doing any work
if (-not (Test-Path -Path $OutputFolder -PathType Container)) {
    Write-Error "Output directory '$OutputFolder' is not accessible."
    exit 1
}

# Import module — #Requires above ensures it is installed
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Import-Module -Name Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell -DisableNameChecking -WarningAction SilentlyContinue
    Write-Host "Running in PowerShell 7+, using -UseWindowsPowerShell"
}
else {
    Import-Module -Name Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -WarningAction SilentlyContinue
    Write-Host "Running in Windows PowerShell"
}

# Connect if not already connected
try {
    Get-SPOSite -Limit 1 | Out-Null
    Write-Host "Already connected to SharePoint Online."
}
catch {
    try {
        Connect-SPOService -Url $TenantUrl
        Write-Host "Connected to SharePoint Online successfully."
    }
    catch {
        Write-Error "Failed to connect to SharePoint Online: $($_.Exception.Message)"
        exit 1
    }
}


# -------------------- Helpers --------------------

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

function Get-SPOSiteUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$SiteUrl,
        [Parameter(Mandatory)] [string]$AdminUpn,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 3
    )

    $result = [pscustomobject]@{
        SiteUrl  = $SiteUrl
        AdminUpn = $AdminUpn
        Elevated = $false
        Users    = $null
        Error    = $null
    }

    try {
        $result.Users = Get-SPOUser -Limit All -Site $SiteUrl -ErrorAction Stop
        return $result
    }
    catch {
        Write-Host "Access denied on $SiteUrl. Temporarily granting SCA to $AdminUpn..." -ForegroundColor Yellow
        $elevated = $false
        $result.Elevated = $true

        try {
            Set-SPOUser -Site $SiteUrl -LoginName $AdminUpn -IsSiteCollectionAdmin $true -ErrorAction Stop
            $elevated = $true

            Start-Sleep -Seconds 2

            $result.Users = Invoke-WithRetry -Script {
                Get-SPOUser -Limit All -Site $SiteUrl -ErrorAction Stop
            } -MaxAttempts $MaxRetries -DelaySeconds $DelaySeconds
            $result.Users = @($result.Users | Where-Object { $_.LoginName -ne $AdminUpn })
            
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


function ConvertTo-StringArray {
    param($Value)
    if (-not $Value) { return @() }
    if ($Value -is [string]) { return @($Value) }
    if ($Value -is [System.Collections.IEnumerable]) { return @($Value | ForEach-Object { "$_" }) }
    return @("$Value")
}

function Get-LoginNameString {
    param($u)
    if ($null -eq $u) { return $null }
    $ln = $null
    if ($u.PSObject.Properties.Name -contains 'LoginName') { $ln = $u.LoginName }
    elseif ($u.PSObject.Properties.Name -contains 'UserPrincipalName') { $ln = $u.UserPrincipalName }
    elseif ($u.PSObject.Properties.Name -contains 'Email') { $ln = $u.Email }
    if ($ln -is [bool]) { return $ln.ToString().ToLower() }
    return [string]$ln
}

function Get-PrincipalType {
    param($u)
    if ($null -eq $u) { return 'User' }
    if ($u.PSObject.Properties.Match('IsGroup').Count -gt 0) {
        return ($(if ($u.IsGroup) { 'Group' } else { 'User' }))
    }
    $hasEmail = ($u.PSObject.Properties.Match('Email').Count -gt 0) -and $u.Email
    if (-not $hasEmail -and ("$($u.LoginName)" -notmatch '@')) {
        return 'Group'
    }
    return 'User'
}


# -------------------- Sites --------------------

Write-Host "Fetching sites..." -ForegroundColor Cyan
$Sites = Get-SPOSite -Limit ALL

if ($UrlIncludes.Count -gt 0) {
    $lowerNeedles = $UrlIncludes | ForEach-Object { $_.ToLowerInvariant() }
    $Sites = $Sites | Where-Object {
        $u = $_.Url.ToString().ToLowerInvariant()
        $null -ne ($lowerNeedles | Where-Object { $u -like "*$_*" } | Select-Object -First 1)
    }
}


# -------------------- Audit --------------------

$all = New-Object System.Collections.Generic.List[object]
$index = 0
$total = ($Sites | Measure-Object).Count
if ($total -eq 0) { Write-Host "No sites to process." -ForegroundColor Yellow }

foreach ($site in $Sites) {
    $index++
    Write-Progress -Activity "Auditing SharePoint permissions" `
        -Status "$index / $total : $($site.Url)" `
        -PercentComplete (([double]$index / [math]::Max(1, $total)) * 100)

    $users = @()
    try {
        $result = Get-SPOSiteUsers -SiteUrl $site.Url -AdminUpn $AdminUpn -MaxRetries $MaxRetries -DelaySeconds $DelaySeconds
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

    $userCount = 0
    $groupCount = 0
    $EUGroupinUse = $false
    $EEEUGroupinUse = $false
    $EditSiteUrl = $TenantUrl + $AdminSiteBuild + $site.SiteId
    $SiteUsers = New-Object System.Collections.Generic.List[object]
    $SiteGroups = New-Object System.Collections.Generic.List[object]

    foreach ($u in @($users | Where-Object { $null -ne $_ })) {
        $ptype = Get-PrincipalType $u
        $login = Get-LoginNameString $u
        $groups = ConvertTo-StringArray $u.Groups

        if ($ptype -eq 'User') {
            $userCount++
            $SiteUsers.Add([pscustomobject]@{
                    DisplayName = $u.DisplayName
                    LoginName   = $login
                    Email       = $u.Email
                    UserType    = $ptype
                    Groups      = $groups
                    SiteAdmin   = $u.IsSiteAdmin
                })
        }

        if ($ptype -eq 'Group' -and $null -ne $groups) {
            $groupCount++
            if ($u.DisplayName -eq "Everyone except external users") { $EEEUGroupinUse = $true }
            if ($u.DisplayName -eq "Everyone") { $EUGroupinUse = $true }
            $SiteGroups.Add([pscustomobject]@{
                    DisplayName = $u.DisplayName
                    LoginName   = $login
                    Email       = $u.Email
                    UserType    = $ptype
                    Groups      = $groups
                    SiteAdmin   = $u.IsSiteAdmin
                })
        }
    }

    $all.Add([pscustomobject]@{
            Name         = $site.Title
            Url          = $site.Url
            UserCount    = $userCount
            groupCount   = $groupCount
            SiteUsers    = $SiteUsers
            SiteGroups   = $SiteGroups
            EditSiteUrl  = $EditSiteUrl
            EUGroupUsed  = $EUGroupinUse
            EEUGroupUSed = $EEEUGroupinUse
        })
}

Write-Progress -Activity "Auditing SharePoint permissions" -Completed


# -------------------- Output JSON --------------------

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Filename = Join-Path $OutputFolder "SPO-Permissions-$timestamp.json"
$all | ConvertTo-Json -Depth 12 | Out-File -FilePath $Filename -Encoding UTF8 -Force

Write-Host ""
Write-Host "  To analyze this file, upload it to:" -ForegroundColor Cyan
Write-Host "    https://purview.expert/tools/spo-permissions" -ForegroundColor Cyan
Write-Host "  Access code: SPOAnalyze" -ForegroundColor Cyan
Write-Host ""
$OpenFile = Read-Host "JSON file generated at $Filename. Would you like to open it? (Y/N)"
if ($OpenFile -eq 'Y' -or $OpenFile -eq 'y') {
    Invoke-Item -Path $Filename
}



