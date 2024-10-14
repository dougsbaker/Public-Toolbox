#https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online

Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name, Version

$tenantURL = "https://dougsbaker-admin.sharepoint.com"
$UserEmail = "doug@dougsbaker.com" #Admin Account that is being used. 
Connect-SPOService -Url $tenantURL


# Output folder path
$OutputFolder = "C:\Output Files"

# Ensure the output directory exists, if not, create it
if (-not (Test-Path -Path $OutputFolder)) {
    Write-Host "Output directory does not exist. Creating directory..."
    New-Item -Path $OutputFolder -ItemType Directory -Force
}
else {
    Write-Host "Output directory exists."
}

# Check if the directory is accessible
if (Test-Path -Path $OutputFolder -PathType Container) {
    Write-Host "Output directory is accessible."
}
else {
    Write-Host "Output directory is not accessible." -ForegroundColor Red
}

# Initialize report array
$Report = @()

# Get all site collections
$Sites = Get-SPOSite -Limit ALL

# Iterate through each site collection
foreach ($Site in $Sites) {
    # Get all users in the site collection
    try {
        $Users = Get-SPOUser -Limit ALL -Site $Site.Url -not
    }
    catch {
        Write-Host "Granting Permision to site for permission check"
        Set-SPOUser -Site $Site.Url -LoginName $UserEmail -IsSiteCollectionAdmin $true
        $Users = Get-SPOUser -Limit ALL -Site $Site.Url
        Set-SPOUser -Site $Site.Url -LoginName $UserEmail -IsSiteCollectionAdmin $false

    }
    $Users = Get-SPOUser -Limit ALL -Site $Site.Url
    $UserCount = 0
    
    Write-Host "Getting Users from Site collection: $($Site.Url)" -ForegroundColor Yellow
    Write-Host "Users" -ForegroundColor Green

    foreach ($User in $Users) {
        if ($User.Groups) {
            Write-Host "it's a Group $($User.DisplayName)" -ForegroundColor Green 
            $Report += New-Object PSObject -Property @{
                'Site'         = $Site.Url
                'Display Name' = $User.DisplayName
                'Login Name'   = $User.LoginName
                'Groups'       = $User.Groups -join ", "  # Convert list of groups to comma-separated string
                'User Type'    = 'Group'
            }
        }
        elseif (-not $User.IsGroup) {
            Write-Host "it's a user $($User.DisplayName)" -ForegroundColor Green 
            $UserCount++
            $Report += New-Object PSObject -Property @{
                'Site'         = $Site.Url
                'Display Name' = $User.DisplayName
                'Login Name'   = $User.LoginName
                'Groups'       = $User.Groups -join ", "  # Convert list of groups to comma-separated string
                'User Type'    = 'User'
            }
        }
        else { 
            Write-Host "it's something else $($User.DisplayName)" -ForegroundColor Red
        }
    }

    # Add total user count for the site collection to the report
    $Report += New-Object PSObject -Property @{
        'Site'         = $Site.Url
        'Display Name' = 'Total User Count'
        'Login Name'   = $UserCount
        'Groups'       = 'Count'
        'User Type'    = 'Special'
    }
}

# Select the desired column order
$Report = $Report | Select-Object 'Site', 'Display Name', 'Login Name', 'Groups', 'User Type'

# Export the report to a CSV file
$CSVPath = Join-Path -Path $OutputFolder -ChildPath "UserReport.csv"
Write-Host "Exporting CSV file to: $CSVPath"

$Report | Export-Csv -Path $CSVPath -NoTypeInformation

# Prompt to open the CSV file
$OpenCSV = Read-Host "CSV file generated at $CSVPath. Would you like to open it? (Y/N)"
if ($OpenCSV -eq 'Y' -or $OpenCSV -eq 'y') {
    Invoke-Item -Path $CSVPath
}
