$PreviewMode = $true
$excludedUsers = "user@tenant.com","user2@tenant.com","user3@test.tenant.com"
$users = Get-User -ResultSize Unlimited
$results = @()
foreach($user in $users){
  if ($user.UserPrincipalName -notin $excludedUsers) {
    
      if ($PreviewMode -eq $false) {
          Set-User -Identity $user.UserPrincipalName -RemotePowerShellEnabled $false
          Write-Host "$user.UserPrincipalName PowerShell Access has been removed"
      }
      $results += New-Object -TypeName psobject -Property @{
          User  = $user.UserPrincipalName
          CurrentStatus = $user.RemotePowerShellEnabled
          ScriptResult = "User Disabled"
          PreviewMode = $PreviewMode
        }
  } else {
      if ($PreviewMode -eq $false) {
          Set-User -Identity $user.UserPrincipalName -RemotePowerShellEnabled $true
          Write-Host "$user.UserPrincipalName PowerShell Access has been enabled"
      }
      $results += New-Object -TypeName psobject -Property @{
          User  = $user.UserPrincipalName
          CurrentStatus = $user.RemotePowerShellEnabled
          ScriptResult = "User Enabled"
          PreviewMode = $PreviewMode
        }
  }
  
}
$results | Out-GridView