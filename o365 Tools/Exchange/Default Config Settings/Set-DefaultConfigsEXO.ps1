# Default Hardening Configs for Exchange Online

# OWA Timeout - SEts to 30 minutues
Get-organizationconfig | fl ActivityBasedAuthenticationTimeoutInterval  
Set-OrganizationConfig -ActivityBasedAuthenticationTimeoutInterval 00:30:00
# Note: It can take 12+ hours for this setting to take effect


#Modern Auth
get-organizationconfig | fl OAuth2ClientProfileEnabled


#IRM Config
Get-IRMConfiguration | fl *azurerms*
Get-IRMConfiguration | fl *Simplified*

#Hosted Filter Polich
Get-HostedOutboundSpamFilterPolicy | select auto*

#Storage Providers
Get-owamailboxpolicy | fl *FileProvidersEnabled

#Get AuditPolicy
Get-AdminAuditLogConfig | FL UnifiedAuditLogIngestionEnabled
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
# Note: May Take 1 hour 

#OME Config
#See OME SEction for Advanced Options Set-OMEBranding.ps1
Get-OMEConfiguration | fl Backgroundcolor,Image,IntroductionText,ReadButtonText,EmailText,DisclaimerText,PortalText
Set-OMEConfiguration -Identity "OME Configuration" -Image (Get-Content "C:\logos\logo.png" -Encoding byte) 

Get-OMEConfiguration | fl SocialIDSignIn
Get-OMEConfiguration | fl OTPEnabled

#Modern Auth
get-organizationconfig | fl OAuth2ClientProfileEnabled 



#Owa Storage Proividers
Get-owamailboxpolicy | fl *FileProvidersEnabled


#Management Role Setup
# Enable option for Disable Forwaring
# https://docs.microsoft.com/en-us/archive/blogs/exovoice/disable-automatic-forwarding-in-office-365-and-exchange-server-to-prevent-information-leakage

New-ManagementRole MyBaseOptions-DisableForwarding -Parent MyBaseOptions
Set-ManagementRoleEntry MyBaseOptions-DisableForwarding\Set-Mailbox -RemoveParameter -Parameters DeliverToMailboxAndForward,ForwardingAddress,ForwardingSmtpAddress


#Disable Enterouge
Get-OrganizationConfig | fl *EWS*
Set-OrganizationConfig -EwsAllowEntourage $False
