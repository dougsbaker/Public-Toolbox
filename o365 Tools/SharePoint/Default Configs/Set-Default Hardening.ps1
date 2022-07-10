# Default Hardening Configs for SPO Online
#Settings you may want to Configure as part of your deployment to Office 365.


#Prevent Download of Malware
#This works with the Office 365 ATP SafeAttachments service which will scan the SharePoint/OneDrive libraries for malware.  If ATP is not licensed, this setting has no effect.  

Get-SPOTenant | fl disallowinfectedfiledownload
#recommend setting this to True (Enabled).
Set-SPOTenant -DisallowInfectedFileDownload $True
#True = Enabled, False = Disabled


#Sensative By Default for DLP
#https://docs.microsoft.com/en-us/sharepoint/sensitive-by-default
get-spotenant | fl MarkNewFilesSensitiveByDefault
#Enable
Set-SPOTenant -MarkNewFilesSensitiveByDefault BlockExternalSharing 
#Disable
Set-SPOTenant -MarkNewFilesSensitiveByDefault AllowExternalSharing



#Disable SPO Default Groups
get-SPOTenant | fl ShowEveryoneClaim, ShowEveryoneExceptExternalUsersClaim,ShowAllUsersClaim
Set-SPOTenant -ShowEveryoneClaim $false
Set-SPOTenant -ShowEveryoneExceptExternalUsersClaim $false
Set-SPOTenant -ShowAllUsersClaim $false

