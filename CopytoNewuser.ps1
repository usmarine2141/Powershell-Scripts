#V2 

Do {
   #Starts logging in the following path
   Start-Transcript -Path C:\Temp\NewUser.log -Append

   #CAPTURES USERNAME TO COPY
   Write-Host "Enter an AD Username to copy: " -ForegroundColor Green -NoNewline
   $InputUser = Read-Host
   $User = Get-AdUser -Identity $InputUser -Properties OfficePhone, Title, Department, State, Streetaddress, City, Country,  Office, HomePage, Fax, Description, co, OfficePhone, PostalCode
   $DN = $User.distinguishedName
   $OldUser = [ADSI]"LDAP://$DN"
   $Parent = $OldUser.Parent
   $OU = [ADSI]$Parent
   $OUDN = $OU.distinguishedName
   
   Write-Host "Enter New Username: " -ForegroundColor Green -NoNewline
   $NewUser = Read-Host
   
   Write-Host "Enter First Name: " -ForegroundColor Green -NoNewline
   $FirstName = Read-Host
   
   Write-Host "Last Name: " -ForegroundColor Green -NoNewline
   $LastName = Read-Host
   
   $NewName = "$firstname $lastname"
   
   Write-Host "Type in the Title of the user: " -ForegroundColor Green -NoNewline
   $title = Read-Host

   Write-Host "Type in the Department of the user: " -ForegroundColor Green -NoNewline
   $Dept = Read-Host

   Write-Host "Type in the Manager name (username): " -ForegroundColor Green -NoNewline
   $mgr = Read-Host

   Write-Host "Domain Name such as `"" -ForegroundColor Green -NoNewline
   Write-Host "Datamartinc.net" -ForegroundColor Yellow -NoNewline
   Write-Host "`": " -ForegroundColor Green -NoNewline
   $Domain = Read-Host
   
   $upn = $NewUser+"@$Domain"
   #if you have to manually enter proxy addresses for O365 modify the prox1/2 variable and add more if needed be sure to add it to the set-aduser command at the end
   #Uncomment the prox1/2 variables if you need these.
   #ALSO UNCOMMENT LINE 115 TO SET THE PROXY ADDRESSES
   #$prox1 = "SMTP:$firstname.$lastname"+"@yourdomain.com"
   #$prox2 = "smtp:$firstname.$lastname"+"@yourdomain.com"
   
   #Sets Email address in AD User account using fn.ln@domain.com
   $email = "$firstname.$lastname"+"@yourdomain.com"
   
   #Sets company name in Org Tab in AD
   $companyname = "Company Name"
   $displayname = "$firstname $lastname"
   
   #Sets Address in AD, These are static variables. 
   $street = "123 lord st Suite 500"
   $state = "NY"
   $city = "New York"
   $zip = "10001"
   $country = "US"
   
   
   #Output what you entered 
   Write-Host "`n---------------------------------------------------------------`n"
   Write-Host "`Username:           " -ForegroundColor Yellow -NoNewline
   Write-Host "$NewUser" 
   Write-Host "First Name:         " -ForegroundColor Yellow -NoNewline
   Write-Host "$FirstName"
   Write-Host "Last Name:          " -ForegroundColor Yellow -NoNewline
   Write-Host "$LastName"
   Write-Host "UPN:                " -ForegroundColor Yellow -NoNewline
   Write-Host "$upn"
   Write-host "Department:         " -ForegroundColor Yellow -NoNewline
   Write-host "$dept"
   Write-host "Title:              " -ForegroundColor Yellow -NoNewline
   Write-host "$title"
   Write-host "Manager:            " -ForegroundColor Yellow -NoNewline
   Write-host "$mgr"
   Write-host "Primary Email:      " -ForegroundColor Yellow -NoNewline
   Write-host "$prox1"
   Write-host "Secondary Email:    " -ForegroundColor Yellow -NoNewline
   Write-host "$prox2"





   Write-Host "Copied User: " -ForegroundColor Yellow -NoNewline
   Write-Host "$InputUser"
   
   Do {
   
   Write-Host "`nPress " -NoNewline
   Write-Host "Y " -ForegroundColor Yellow -NoNewline
   Write-Host "to confirm and " -NoNewline
   Write-Host "N " -ForegroundColor Yellow -NoNewline
   Write-Host "to redo: " -NoNewline
   $confirm = Read-Host
   
   } until (($Confirm -eq 'y') -or ($Confirm -eq 'n'))
   
   
   
   
   
   if($Confirm -eq 'y') 
   {
   New-ADUser -SamAccountName $NewUser -userPrincipalName $upn -Name $NewName -GivenName $firstname -Surname $lastname -Instance $DN -Path "$OUDN" -AccountPassword (Read-Host "New Password: " -AsSecureString) –ChangePasswordAtLogon $false
   Get-ADUser -Identity $InputUser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $NewUser
   Set-ADUser -Identity $Newuser -Description $title -Title $title -Department $dept -Company $companyname -Manager $mgr -StreetAddress $street -City $city -State $state -PostalCode $zip -country $country 
   Set-ADUser -Identity $NewUser -CannotChangePassword:$False -PasswordNeverExpires:$False
   Set-ADUser -Identity $NewUser -DisplayName $displayname
   #UNCOMMENT THIS BELOW IF NEED TO SET PROXY ADDRESSES
   #Set-ADUser $newuser -add @{ProxyAddresses="$prox1,$prox2" -split ","}
   set-aduser $NewUser -EmailAddress $email
   Enable-ADAccount -Identity $NewUser
   
   $Completed = "y"
   ; $Confirm ="n"}
   
      else {Clear-Host
      }
   
   
         }
   
   Until ($Completed -eq "y")
   
   Write-Host "AD User Creation Completed Successfully"
