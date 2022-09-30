Connect-MsolService
$Admins = @();$roles = Get-MsolRole; foreach($role in $roles){ $users= Get-MsolRoleMember -RoleObjectId $role.ObjectId |Get-MsolUser |where-Object {$_.ImmutableId -ne $null}; foreach ($user in $users) { $Admins += New-Object -TypeName psobject -property @{ role = $role.Name; user = $user.UserPrincipalName; onpremid = $user.ImmutableID;  }}};$admins
