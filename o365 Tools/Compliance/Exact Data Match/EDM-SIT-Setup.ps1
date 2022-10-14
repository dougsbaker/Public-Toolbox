Connect-IPPSSession

#Get Rule Package
get-DlpSensitiveInformationTypeRulePackage

#Create Rule Package
#https://learn.microsoft.com/en-us/microsoft-365/compliance/sit-get-started-exact-data-match-create-rule-package?view=o365-worldwide
$rulepack = Get-Content "C:\VSCode\Public-Toolbox\o365 Tools\Compliance\Exact Data Match\DLP-Schema-MSFT.xml" -Encoding Byte -ReadCount 0
New-DlpSensitiveInformationTypeRulePackage -FileData $rulepack

Set-DlpSensitiveInformationTypeRulePackage -FileData $rulepack

#Delete Rule Pack
get-DlpSensitiveInformationTypeRulePackage  "Policy Name" | Remove-DlpSensitiveInformationTypeRulePackage