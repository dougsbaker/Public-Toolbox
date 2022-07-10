
#Exchange Commands
Connect-O365Exchange
#NotWorking
<#
Get-ExoInformationBarrierPolicy -ShowFriendlyValues
Get-InformationBarrierReportSummary
Get-InformationBarrierReportDetails
#>



Connect-IPPSSession

get-OrganizationSegment
Get-InformationBarrierPolicy
Start-InformationBarrierPoliciesApplication
Get-InformationBarrierPoliciesApplicationStatus
Get-InformationBarrierPoliciesApplicationStatus -All

Start-InformationBarrierPoliciesApplication

Get-InformationBarrierRecipientStatus -Identity "<value>" -Identity2 "<value>"

Get-InformationBarrierRecipientStatus -Identity IB-UKUser -Identity2 IB-RussiaUser

Get-InformationBarrierRecipientStatus -Identity IB-UKUser

Get-OrganizationSegment


#SharePoint
# https://www.microsoft.com/en-us/download/details.aspx?id=35588
# Update Policy module

Connect-SPOService -Url "https://tenant-admin.sharepoint.com/"

get-spotenant | fl Information*, IB*

Set-SPOTenant -InformationBarriersSuspension $false 
Set-SPOTenant -IBImplicitGroupBased $true

Get-SPOSite | ft Title, InformationBarriersMode, InformationSegment, url
Get-SPOSite -Identity https://tenant.sharepoint.com/sites/USSales | Select InformationSegment


#Set SPO Segments
Set-SPOSite -Identity https://tenant.sharepoint.com/sites/NewHires -InformationBarriersMode OwnerModerated
#KB ARcicles
# SPO
# https://docs.microsoft.com/en-us/sharepoint/information-barriers#segments-associated-with-microsoft-teams-sites

Get-OrganizationSegment | ft Name, EXOSegmentID

