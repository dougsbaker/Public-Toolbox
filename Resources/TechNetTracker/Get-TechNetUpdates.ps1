#Get the Latest Tech net Updates

#Storage Location of Files that will be used for comparision and final report
$FileStorage = "C:\TechNetNew\"
$Launch = $FileStorage + "Updatelog.html"
start-process $Launch

$Date = get-date
#Add all Technet Articles below that you want to follow. 

$Websites = @()
$Websites += New-Object PSObject -Property @{ Name = "AzureAD"; URL = "https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/whats-new" }
$Websites += New-Object PSObject -Property @{ Name = "MDCS"; URL = "https://docs.microsoft.com/en-us/cloud-app-security/release-notes" }
$Websites += New-Object PSObject -Property @{ Name = "Compliance"; URL = "https://docs.microsoft.com/en-us/microsoft-365/compliance/whats-new" }
$Websites += New-Object PSObject -Property @{ Name = "Defender"; URL = "https://docs.microsoft.com/en-us/microsoft-365/security/defender/whats-new" }
$Websites += New-Object PSObject -Property @{ Name = "MDI"; URL = "https://docs.microsoft.com/en-us/defender-for-identity/whats-new" }
$Websites += New-Object PSObject -Property @{ Name = "MDI Event Log"; URL = "https://docs.microsoft.com/en-us/defender-for-identity/configure-windows-event-collection" }
$Websites += New-Object PSObject -Property @{ Name = "MDE"; URL = "https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/whats-new-in-microsoft-defender-endpoint" }
$Websites += New-Object PSObject -Property @{ Name = "MDO"; URL = "https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/whats-new-in-defender-for-office-365" }
$Websites += New-Object PSObject -Property @{ Name = "MDO Safe Sender List"; URL = "https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/create-safe-sender-lists-in-office-365" }
$Websites += New-Object PSObject -Property @{ Name = "AuditLogs"; URL = "https://docs.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing" }
$Websites += New-Object PSObject -Property @{ Name = "Sentinel"; URL = "https://docs.microsoft.com/en-us/azure/sentinel/whats-new" }
$Websites += New-Object PSObject -Property @{ Name = "SeacrchAuditLogs"; URL = "https://docs.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log-in-security-and-compliance" }
$Websites += New-Object PSObject -Property @{ Name = "CloudSync"; URL = "https://docs.microsoft.com/en-us/azure/active-directory/cloud-sync/reference-version-history" }
$Websites += New-Object PSObject -Property @{ Name = "AD Connect"; URL = "https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-version-history" }
$Websites += New-Object PSObject -Property @{ Name = "AD External Identitys"; URL = "https://docs.microsoft.com/en-us/azure/active-directory/external-identities/whats-new-docs" }
$Websites += New-Object PSObject -Property @{ Name = "MIP Label Office Configs"; URL = "https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-office-apps?view=o365-worldwide" }

#Object Variables and Header of Report
$log = @()
$UpdateLog = "<html><head><base href='https://docs.microsoft.com/' target='_blank'>
                    <style>
                    .Article { border: 1px solid lightgray;
                        padding: 5px;
                        margin: 5px;
                        background: rgba(205, 205, 205, .2);
                        border-radius: 7px;
                        
                        }
                .Title {
                    word-wrap: break-word;
                    font-size: clamp(1.875rem,22.1052631579px + 1.6447368421vw,2.5rem);
                    line-height: 1.3;
                    margin-bottom: 4px;
                    margin-top: 0;
                    word-break: break-word;
                }
                .docupdate {
                    Float: Left
                }
                .legend{
                    float: right;
                } 
            </style>
            <link rel='stylesheet' href='/_themes/docs.theme/master/en-us/_themes/styles/9f4dd321.site-ltr.css '></head><body> <div class='Header'><div class='Docupdate'><h2 class='Title'>TechNet updates: $date</h2></div> <div class='Legend'>Legend: <b style='background-color: orange;'>Removed</b> <b style='background-color: lightgreen;'>Added</b></div>
            </div>"


#Create Repo Folder if Not Exist
if (-not(test-path $FileStorage)) {
    Write-Host "Creating File $FileStorage"
    try {
        $null = New-Item -ItemType Directory -Path $FileStorage -Force -ErrorAction Stop
        Write-Host "The fodler [$FileStorage] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
#Start of Get for Articles
foreach ($Site in $Websites) {

    $CData = Invoke-WebRequest $Site.URL -UseBasicParsing
    $url = $site.URL
    $Name = $site.name
    $HTML = New-Object -Com "HTMLFile"
    $HTML = $cdata.content
    #$html.IndexOf("name=ms.date content=")
    if ($html.IndexOf('"updated_at" content="') -gt 1 ) {
        $PageUpdate = $html.Substring($html.IndexOf('"updated_at" content="') + 22, $html.Substring($html.IndexOf('"updated_at" content="') + 25).IndexOf(">"))
    }
    elseif ($html.IndexOf("name=ms.date content=") -gt 1 ) {
        $PageUpdate = $html.Substring($html.IndexOf("name=ms.date content=") + 21, $html.Substring($html.IndexOf("name=ms.date content=") + 21).IndexOf(">"))
    }
    else {
        $PageUpdate = "Date not Found"
    }
    $content = $cdata.content.Substring($CData.content.IndexOf("<!-- <content> -->"), $cdata.content.Substring($CData.content.IndexOf("<!-- <content> -->")).IndexOf("<!-- </content> -->")) 


    
    $SaveFile = $FileStorage + $site.Name + ".html"
    $CompareFile = $FileStorage + $site.Name + ".old.html"
    #Create First Time Report
    if (-not(test-path $saveFile)) {
        Write-Host "Creating File $SaveFile"
        try {
            $null = New-Item -ItemType File -Path $SaveFile -Value "Newley Added Article." -Force -ErrorAction Stop
            Write-Host "The file [$SaveFile] has been created."
        }
        catch {
            throw $_.Exception.Message
        }
    }
    #Move Old File
    move-Item -path $SaveFile -destination $CompareFile -Force
    #Create New File
    $content | Out-File -FilePath $SaveFile
    #Compare new to Old
    $Compare = compare-object (get-content $SaveFile)  -DifferenceObject (get-content $CompareFile) -PassThru 
    

    $log += New-Object PSObject -Property @{
        url         = $url
        Update      = $PageUpdate
        PageContent = $content
        Compare     = $compare
    }

    $CompareHTML = $null
    Foreach ($side in $compare) {
        if ($Side.SideIndicator -eq "<=") {
            # Write-Host "Left Side"
            $comparehtml += '<div class="change" style="background-color: lightgreen;">'
            $comparehtml += "$side"
            $comparehtml += "</div>"
        }
        elseif ($Side.SideIndicator -eq "=>") {
            #Write-Host "Right Side"
            $comparehtml += '<div class="compare" style="background-color: orange;">'
            $comparehtml += "$side"
            $comparehtml += "</div>"
        }
        else {
            #Write-Host "Right Side"
            $comparehtml += '<div">'
            $comparehtml += "No Changes"
            $comparehtml += "</div>"
        }
      
    }

    $UpdateLog += "<section class='Article'><h2 class='Title'><a href='$url'  target='_blank'>$name</a></h2>
                <a href='$url' target='_blank'>$url</a>
                <h3 class='ArticleUpdate'><b>Site Update:</b>$PageUpdate</h3> 
                </br>
                $CompareHTML
                </section>"

}
$UpdateLog += "</body></html>"

$log | ft Update, URL, compare
$UpdateLog | Out-File $FileStorage"Updatelog.html"
$Launch = $FileStorage + "Updatelog.html"
start-process $Launch