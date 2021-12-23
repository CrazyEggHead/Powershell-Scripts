
Import-Module ActiveDirectory

#================================================================================================================================================

# Collect username and optional groups to add user to. 
$UserFirstName = Read-Host -Prompt "User's first name"
Write-Host `n
$UserLastName = Read-Host -Prompt "User's last name"
Write-Host `n
$Building = Read-Host -Prompt "Which Building,  A or B? "
Write-Host `n
$CadUser = Read-Host -Prompt "Is this a CAD User?  Y or N? "

# Set up username variables to use later
$ADLogonName = "$UserFirstName.$UserLastName"  # "first.last" name
$ADUserDistName = "$UserFirstName $UserLastName" # "first last" name

# Define variables to be used to add user
$Username    = $ADUserDistName
$Password    = ConvertTo-SecureString -String "TempP@ssWord12" -AsPlainText -Force
$Firstname   = $UserFirstName
$Lastname    = $UserLastName
$OU          = "OU=Active Employees,OU=SBSUsers,OU=Users,OU=MyBusiness,DC=domain,DC=local"
$domainLocal = '@domain.local'
$domainCom = '@domain.com'
$domainOnmicrosoft = '@domain.onmicrosoft.com'





       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
          #If a user does not exist then create a new user account
          New-ADUser -SamAccountName $Username -UserPrincipalName "$Username$domainLocal" -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$FirstName, $LastName" -Path $OU -AccountPassword $Password

       }



# Add attributes to account
Set-ADUser -Identity $ADUserDistName -Add @{ProxyAddresses="SMTP:$ADLogonName$domainCom"}
Set-ADUser -Identity $ADUserDistName -Add @{ProxyAddresses="smtp:$ADLogonName$domainOnmicrosoft"}
Set-ADUser -Identity $ADUserDistName -Add @{Mail = "$ADLogonName$domainCom"}
Set-ADUser -Identity $ADUserDistName -Add @{MailNickName = "$ADLogonName"}

# Add members to groups
Add-ADGroupMember -Identity "All Users" -Members "$ADUserDistName"
Add-ADGroupMember -Identity "Domain Location" -Members "$ADUserDistName"
Add-ADGroupMember -Identity "Domain Standard Access" -Members "$ADUserDistName"
Add-ADGroupMember -Identity "Domain Shared" -Members "$ADUserDistName"
Add-ADGroupMember -Identity "VPN Access" -Members "$ADUserDistName"

if ($Building -eq "a"){
    Add-ADGroupMember -Identity "BuildingA" -Members "$ADUserDistName"
    }
if ($Building -eq "b"){
    Add-ADGroupMember -Identity "BuildingB" -Members "$ADUserDistName"
    }

if ($CadUser -eq "y"){
    Add-ADGroupMember -Identity "Cad users" -Members "$ADUserDistName"
    }

    write-host "Processing request, please wait..." #Pause needed before displaying which groups user is a member of to work
    start-sleep (15)
#====================================================================================================
# Show output of settings applied

Write-Host `n
Write-Host "Now showing the user properties as reported by AD: `n"
Get-ADUser -Identity $ADUserDistName

Write-Host "Your new user is a member of the following groups:" -ForegroundColor Yellow

$showgroups = @()
Get-ADPrincipalGroupMembership $ADUserDistName | Sort-Object Name | Select-Object name | Format-table

#====================================================================================================
