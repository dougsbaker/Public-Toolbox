#Enable Bookings
#https://docs.microsoft.com/en-us/microsoft-365/bookings/bookings-in-outlook?view=o365-worldwide

get-organizationconfig | FL ews*
Get-OrganizationConfig | Format-List EwsEnabled
Get-OrganizationConfig | Format-List EwsApplicationAccessPolicy,Ews*List
Set-OrganizationConfig -EwsEnabled: $true
Set-OrganizationConfig -EwsAllowList @{add="MicrosoftOWSPersonalBookings"}


Get-CASMailbox -Identity doug@dougsbaker.com | Format-List Ews*
Get-CASMailbox -Identity doug@dougsbaker.com | Format-List EwsApplicationAccessPolicy,Ews*List
set-CASMailbox -Identity doug@dougsbaker.com -EwsAllowList @{Add="MicrosoftOWSPersonalBookings"}