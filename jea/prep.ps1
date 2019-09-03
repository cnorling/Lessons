<# 
this document is used to prepare a lab environment to demonstrate JEA's capabilities. 
The core requirements for the demonstration are:
* A domain controller
* A source server
* A destination server

All these virtual machines will be setup with hyper-v.
#>

## preemptive work
$accounts = @{
    # create a credential object for your domain admin creds
    domainadmin = @{
        username = "home.lab\administrator"
        password = ConvertTo-SecureString -AsPlainText -Force -String "Homelab!"
    }
    # create a credential object for your local admin password (to setup all 3 machines)
    localadmin = @{
        username = "administrator"
        password = ConvertTo-SecureString -AsPlainText -force -String "Homelab!"
    }
    # create a credential object for bob
    bob = @{
        username = "home.lab\Bob.Saget"
        password = ConvertTo-SecureString -AsPlainText -force -String "Your password sucks bob1"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.username,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.username,$accounts.localadmin.password
    bob = new-object pscredential -argumentlist $accounts.bob.username,$accounts.bob.password
}

## setup DOMAIN-1
# create the VM
New-VMFromTemplate -name "DOMAIN-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\template.vhdx" -switch "domain" -memory 1

# rename the computer and set a static IP address, and add some windowsfeatures
Invoke-Command -VMname "DOMAIN-1"-Credential $credential.localadmin {
    New-NetIPAddress -IPAddress "10.10.10.10" -InterfaceIndex (Get-NetAdapter).interfaceindex -DefaultGateway "10.10.10.1" -PrefixLength 24
    Install-WindowsFeature -Name "RSAT-AD-Tools","DNS","DHCP","AD-Domain-Services"
    Rename-Computer -NewName "DOMAIN-1" -Restart
}

# create the domain HOME.LAB
$param = @{
    creatednsdelegation = $false
    databasepath = "C:\windows\NTDS"
    domainmode = "Win2012R2"
    domainname = "home.lab"
    domainnetbiosname = "home"
    forestmode = "Win2012R2"
    installdns = $true
    logpath = "C:\windows\NTDS"
    norebootoncompletion = $false
    sysvolpath = "C:\Windows\SYSVOL"
    force = $true
    safemodeadministratorpassword = $using:accounts.domainadmin.password
}
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.localadmin {
    Install-ADDSForest @using:param
}

# create a domain account, a group, and a GMSA to use ... and a KDS root key so you can make GMSAs before the 10 hour convergence cycle
# https://social.technet.microsoft.com/Forums/ie/en-US/82617035-254f-4078-baa2-7b46abb9bb71/newadserviceaccount-key-does-not-exist?forum=winserver8gen
$user = @{
    name = "Bob.Saget"
    SamAccountName  = "Bob.Saget"
    accountpassword = $accounts.bob.password
    enabled = $true
    path = "CN=Users,DC=home,DC=lab"
}
$group = @{
    name = "JEA_Group"
    SamAccountName = "JEA_Group"
    displayname = "JEA_Group"
    groupcategory = "Security"
    groupscope = "Global"
    path = "CN=Users,DC=home,DC=lab"
}
$gmsa = @{
    name = "JEA_GMSA"
    dnshostname = "JEA_GMSA.home.lab"
}
invoke-command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    Add-KdsRootKey –EffectiveTime ((get-date).addhours(-10))
    New-ADUser @using:user
    New-ADGroup @using:group
    New-ADServiceAccount @using:gmsa
}

## setup SERVER-1
# create the VM
# rename the computer
# join the HOME.LAB domain

## setup SERVER-2
# create the VM
# rename the computer
# join the HOME.LAB domain