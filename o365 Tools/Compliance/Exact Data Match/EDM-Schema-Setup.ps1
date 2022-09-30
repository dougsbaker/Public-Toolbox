
Connect-IPPSSession

#Create Schema
# https://learn.microsoft.com/en-us/microsoft-365/compliance/sit-get-started-exact-data-match-create-schema?view=o365-worldwide#using-the-caseinsensitive-and-ignoreddelimiters-fields
$edmschemaXML = Get-Content "C:\scripts\DLP-Test-Schema.xml" -Encoding Byte -ReadCount 0
#Create
New-DlpEdmSchema -FileData $edmSchemaXml -Confirm:$true
#update
Set-DlpEdmSchema -FileData $edmSchemaXml -Confirm:$true
#Get
Get-DlpEdmSchema
