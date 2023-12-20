#KB article
#https://docs.microsoft.com/en-us/microsoft-365/compliance/enable-mailbox-auditing?view=o365-worldwide#mailbox-actions-for-user-mailboxes-and-shared-mailboxes

#Check Audit Log Status
$FormatEnumerationLimit = -1
Get-Mailbox -ResultSize Unlimited | select Name, email, AuditEnabled, AuditLogAgeLimit, Auditowner, auditdelegate, AuditAdmin  | Out-Gridview


# add 1 record for a single user
Get-Mailbox user@dougsbaker.com | set-mailbox -Auditadmin @{Add = "MailItemsAccessed" } -AuditOwner @{Add = "MailItemsAccessed" } -Auditdelegate @{Add = "MailItemsAccessed" }


#Enable global audit logging
Get-Mailbox -ResultSize Unlimited -Filter `
{ RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox" } `
| Select PrimarySmtpAddress `
| ForEach { $_.PrimarySmtpAddress
  Set-Mailbox -Identity $_.PrimarySmtpAddress -AuditEnabled $true -AuditLogAgeLimit 180 `
    -AuditAdmin   @{add = "ApplyRecord", "Copy", "Create", "FolderBind" , "HardDelete", "MailItemsAccessed", "Move", "MoveToDeletedItems", "RecordDelete", "Send", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateComplianceTag", "UpdateFolderPermissions", "UpdateInboxRules" } `
    -AuditDelegate @{add = "ApplyRecord", "Create", "FolderBind" , "HardDelete", "MailItemsAccessed" , "Move", "MoveToDeletedItems", "RecordDelete", "SendAs", "SendOnBehalf", "SoftDelete", "Update", "UpdateComplianceTag", "UpdateFolderPermissions", "UpdateInboxRules" } `
    -AuditOwner  @{add = "ApplyRecord", "Create", "HardDelete", "MailItemsAccessed", "MailboxLogin", "Move", "MoveToDeletedItems", "RecordDelete", "Send", "SoftDelete", "Update", "UpdateCalendarDelegation", "UpdateComplianceTag", "UpdateFolderPermissions", "UpdateInboxRules", "SearchQueryInitiated" }
}





#Audit Quick
Get-Mailbox -ResultSize Unlimited -Filter { RecipientTypeDetails -eq "UserMailbox" } | group  auditdelegate | sort-object count | fl Count, Name

