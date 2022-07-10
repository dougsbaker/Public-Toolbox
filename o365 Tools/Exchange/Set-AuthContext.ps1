Get-AuthenticationPolicy

New-AuthenticationPolicy -Name "Block Basic Authentication"

get-AuthenticationPolicy -identity "Block Basic Authentication"

Set-AuthenticationPolicy -identity "Block Basic Authentication" -AllowBasicAuthMapi:$true

get-user -Identity "user@dougsbaker.com" | select Auth*

set-user -Identity "user@dougsbaker.com" -AuthenticationPolicy "Block Basic Authentication"

<#
RunspaceId                         : 6ba5f153-5503-4dc5-9ee2-d3ec3e9267d9
AllowBasicAuthActiveSync           : True
AllowBasicAuthAutodiscover         : True
AllowBasicAuthImap                 : False
AllowBasicAuthMapi                 : True
AllowBasicAuthOfflineAddressBook   : True
AllowBasicAuthOutlookService       : True
AllowBasicAuthPop                  : False
AllowBasicAuthReportingWebServices : True
AllowBasicAuthRest                 : False
AllowBasicAuthRpc                  : True
AllowBasicAuthSmtp                 : False
AllowBasicAuthWebServices          : True
AllowBasicAuthPowershell           : False
AdminDisplayName                   :
#>