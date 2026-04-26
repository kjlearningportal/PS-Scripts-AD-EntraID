#  USER MANAGEMENT — ON-PREM ACTIVE DIRECTORY
#
#   .SYNOPSIS  Creates multiple AD user accounts from a CSV file.
#   .DESCRIPTION
#        CSV must have columns (case-insensitive):
#        FirstName, LastName, SamAccountName,UPN,OU,Department,Title
# 		 John,Doe,jdoe,jdoe@ADTech.com,"OU=Users,DC=ADTech,DC=com",IT,Engineer
#    
#

Import-Module ActiveDirectory

# Password profile for all users
$PasswordProfile = @{
    Password                             = "TempP@ssw0rd!"
}

# Import CSV
$users = Import-Csv -Path "C:\KJ\Client-Projects\NewBulkUsers.csv"

Write-Host "`nProcessing $($users.Count) user(s) from $CsvPath`n" -ForegroundColor Cyan
foreach ($u in $users) {
    $securePwd = ConvertTo-SecureString $u.Password -AsPlainText -Force

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name "$($u.FirstName) $($u.LastName)" `
            -GivenName $u.FirstName `
            -Surname $u.LastName `
            -SamAccountName $u.SamAccountName `
            -UserPrincipalName $u.UPN `
            -Path $u.OU `
            -Department $u.Department `
            -Title $u.Title `
            -AccountPassword $securePwd `
            -Enabled $true `
            -ChangePasswordAtLogon $true
        Write-Host "SUCCESS - Created: $($u.SamAccountName)" -ForegroundColor Green
    } else {
        Write-Warning "Exists: $($u.SamAccountName)" -ForegroundColor Red
    }
}