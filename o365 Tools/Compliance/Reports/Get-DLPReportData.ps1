

$ExportDirectory = "C:\VSCode\Data\"
$DaysBack = 15
$PageSize = 1000
$date = Get-Date '08:00'
$date.AddDays(-$DaysBack)

#Connecto Exchange and Compliance Center
try {
    Get-AcceptedDomain -ErrorAction Stop > $null
    Write-Host "Connected to Exchange Online"
}
catch {
    Write-Host "Connecting to Exchange Online"
    Connect-ExchangeOnline
}

try {
    Get-ComplianceCase -ErrorAction Stop > $null
}
catch {
    Connect-IPPSSession
}


#Create Directorys

$ExDLP = "DLP\"
if (-not (test-path $ExportDirectory$ExDLP)) {
    New-Item -Path $ExportDirectory$ExDLP -ItemType Directory

}
$ExSIT = "SIT\"
if (-not (test-path $ExportDirectory$ExSIT)) {
    New-Item -Path $ExportDirectory$ExSIT -ItemType Directory

}

#Export Data
$a = 1
$results = $null
$ResultData = $null
Do {
    
    $StartDate = $date.AddDays(-$DaysBack)
    Write-host "Retrieving Data from: $StartDate" 
    #$StartDate
    $EndDate = $StartDate.AddDays(1)
    Write-host "Retrieving Data to: $EndDate" 
    #$EndDate

    $a = 1
    $results = $null
    $ResultData = $null
    DO {
        Write-Host "Downloading Page $a"
               
        $results = export-activityexplorerdata  -EndTime $EndDate -StartTime $StartDate -Filter1 @("Activity", "DLPRuleMatch") -PageSize $PageSize -OutputFormat json -PageCookie $results.WaterMark
        Write-Host "ResultCount:" $results.TotalResultCount
        Write-Host "RecordCount:"$results.RecordCount
        Write-Host "LastPage:"$results.LastPage
        $ResultData = $results.ResultData
        $dateStr = (Get-Date $StartDate -Format "yyyMMdd")
        $ResultData | Out-File "$ExportDirectory$ExDLP$dateStr-$a.json" -Force
        $a++
    } Until ($results.LastPage -eq $true)


    $DaysBack--  
} until (
    $DaysBack -eq 0
)

Write-Host "Downloading Sensitive Info Definitions"
$sit = Get-DlpSensitiveInformationType 
$SitExport = $ExportDirectory + $ExSIT + "SitNames.csv"
$sit | Export-Csv -path $SitExport -NoTypeInformation

