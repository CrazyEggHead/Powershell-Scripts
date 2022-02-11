
Import-Module ActiveDirectory

#================================================================================================================================================

# Collect username and password
$UserFirstName = Read-Host -Prompt "User's first name"
Write-Host `n
$UserLastName = Read-Host -Prompt "User's last name"
Write-Host `n
$Building = Read-Host -Prompt "Which 75x Building,  A or B? "
Write-Host `n
$CadUser = Read-Host -Prompt "Is this a CAD User?  Y or N? "

# Set up some username variables to use later
$ADLogonName = "$UserFirstName.$UserLastName"
$ADUserDistName = "$UserFirstName $UserLastName"

# Define variables to be used to add user
$Username    = $ADUserDistName
$Password    = ConvertTo-SecureString -String "P@SSW0RD1" -AsPlainText -Force
$Firstname   = $UserFirstName
$Lastname    = $UserLastName
$OU          = "OU=Active Employees,OU=SBSUsers,OU=Users,OU=MyBusiness,DC=contoso,DC=local"

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
          #If a user does not exist then create a new user account
          New-ADUser -SamAccountName $ADLogonName -UserPrincipalName "$ADLogonName@contoso.local" -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$FirstName $LastName" -Path $OU -AccountPassword $Password

       }



# Add attributes to account
Set-ADUser -Identity $ADLogonName -Add @{ProxyAddresses="SMTP:$ADLogonName@contoso.com"}
Set-ADUser -Identity $ADLogonName -Add @{ProxyAddresses="smtp:$ADLogonName@contoso.onmicrosoft.com"}
Set-ADUser -Identity $ADLogonName -Add @{Mail = "$ADLogonName@contoso.com"}
Set-ADUser -Identity $ADLogonName -Add @{MailNickName = "$ADLogonName"}

# Add members to groups
Add-ADGroupMember -Identity "All Users" -Members "$ADLogonName"
Add-ADGroupMember -Identity "Contoso Standard Access" -Members "$ADLogonName"
Add-ADGroupMember -Identity "Contoso Shared" -Members "$ADLogonName"
Add-ADGroupMember -Identity "Virtual Private Network Users" -Members "$ADLogonName"

if ($Building -eq "a"){
    Add-ADGroupMember -Identity "75A" -Members "$ADLogonName"
    }
if ($Building -eq "b"){
    Add-ADGroupMember -Identity "75B" -Members "$ADLogonName"
    }

if ($CadUser -eq "y"){
    Add-ADGroupMember -Identity "Cad users" -Members "$ADLogonName"
    }
	
	write-host "Creating user account under My Business > Users > SBSUsers > Active Employees "
    write-host "Processing request, please wait..."
    start-sleep (15)
#====================================================================================================
# Show output of settings applied
#
Write-Host `n
Write-Host "Now showing the user properties as reported by AD: `n"
$ShowADUser = Get-ADUser -Identity $ADLogonName
$ShowADUser
#
Write-Host "Your new user is a member of the following groups:" -ForegroundColor Yellow
#
$showgroups = @()
$ShowAdGroups = Get-ADPrincipalGroupMembership $ADLogonName | Sort-Object Name | Select-Object name | Format-table
$ShowAdGroups 
#====================================================================================================

#Email Section

## This section needs help, broken.  


$MailFrom = 'systems@contoso.com'
$MailTo = 'user@contoso.com'
$MailServer = 'contoso.mail.protection.outlook.com'

$MailBody = "New User Created: $ADUserDistName" + '<br>' + "$ShowADUser" + '<br>' + "$ShowAdGroups"
$mailBody = $MailBody | Out-String
$MailSubject = "New AD User created on Domain Controller"


#Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -BodyAsHtml -Body $MailBody -SmtpServer $MailServer 
