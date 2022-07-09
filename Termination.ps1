
# Start Transcript
Start-Transcript -Path C:\Temp\Termination.log -Append


write-host 'Importing Active ActiveDirectory Module' -ForegroundColor Yellow
# Import AD Module
Import-Module ActiveDirectory
[System.Environment]::NewLine
[System.Environment]::NewLine

Write-host "Getting Info About the Account" -ForegroundColor Green
[System.Environment]::NewLine

#Get Username
Write-host  "Input the user name to modify: " -ForegroundColor Green -NoNewLine
$User=Read-Host 

$UserGroups = Get-Adprincipalgroupmembership -Id $User | Select-Object -ExpandProperty samaccountname

#Generate an array from 0 to total number of groups in $UserGroups
$GroupIndex = 0..($UserGroups.count - 1)

foreach($Index in $GroupIndex)
{
    $CurrentGroup = $UserGroups[$Index]
    write-host "$Index) $CurrentGroup"
}

Write-host "Enter the corresponding group number to delete. For multiple groups, seperate each w/ a comma: " -ForegroundColor Green -NoNewLine
$SelectGroupIndex = Read-Host 

$MultiGroupIndex = $SelectGroupIndex -split ","

foreach($Index in $MultiGroupIndex)
{
    $GroupToDelete = $UserGroups[[int]$Index]
    write-host "You're deleting the user from group(s): $GroupToDelete" -ForegroundColor Green
    remove-adgroupmember -identity $GroupToDelete -members $user
}



write-host 'Now we will reset the password for the user' -ForegroundColor Green

#Sets AD Password
$password= (Read-Host -Prompt "Provide New Password for the user: " -AsSecureString) 
[System.Environment]::NewLine

#Changes AD Password
set-adaccountpassword -identity $user -NewPassword $password -Reset
[System.Environment]::NewLine

write-host 'Password Set' -ForegroundColor Green
[System.Environment]::NewLine
[System.Environment]::NewLine

#Notify goingn to connect to O365 to sign out of all Sessions
write-host 'Now we will sign them out of O365 Sessions' -ForegroundColor Green
Write-host 'Installing dependencies for AzureAD and O365' -ForegroundColor Green
[System.Environment]::NewLine

#installing azure AD
$AzureIsInstalled = Get-Module AzureAD
if(!$AzureIsInstalled)
{
    write-host "Installing AzureAD module..."
    Install-Module AzureAD
}
#install MSONLINE
#Install-Module MSOnline
#Connect to O365 
write-host "Connecting to Azure AD now" -ForegroundColor Green
write-host "DO NOT HIT ENTER AT PASSWORD PROMPT, CLICK SIGNIN" -ForegroundColor Red
Connect-AzureAD


#Get user account in Azure
write-host 'Input Username (username@domain.com): ' -ForegroundColor Green -NoNewLine
$name= read-host
Revoke-AzureADUserAllRefreshToken -ObjectId $name
[System.Environment]::NewLine
[System.Environment]::NewLine
write-host "Revoked object ID for user $Name" -ForegroundColor Green

write-host 'We have initiated a sign-out for the user. It may take some time to sign out the user from all sessions on all devices.' -ForegroundColor Green


