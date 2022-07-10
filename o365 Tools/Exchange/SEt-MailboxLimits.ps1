# Connect to Exchange Online

# Get the mailbox size limits
Get-Mailbox -identity user@test.dougsbaker.com | select IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota
# Get all mailbox sizes
Get-Mailbox | select DisplayName, IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota

# Increase mailbox size
Set-Mailbox -identity user@test.dougsbaker.com -IssueWarningQuota 90GB -ProhibitSendQuota 96GB -ProhibitSendReceiveQuota 99GB

#Set All Mailboxes
Get-mailbox -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-mailbox -ProhibitSendQuota 98GB -ProhibitSendReceiveQuota 99GB -IssueWarningQuota 95GB