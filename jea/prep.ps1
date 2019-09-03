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
        user = "home.lab\domain admin"
        password = ConvertTo-SecureString -AsPlainText -Force -String "domainadminpassword"
    }
    # create a credential object for your local admin password (to setup all 3 machines)
    localadmin = @{
        user = "administrator"
        password = ConvertTo-SecureString -AsPlainText -force -String "localadminpassword"
    }
    # create a credential object for bob
    bob = @{
        user = "home.lab\bob"
        password = ConvertTo-SecureString -AsPlainText -force -String "Your password sucks bob1"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.user,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.user,$accounts.localadmin.password
    bob = new-object pscredential -argumentlist $accounts.bob.user,$accounts.bob.password
}

## setup DOMAIN-1
# create the VM
New-VMFromTemplate -name "DOMAIN-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\template.vhdx" -switch "domain" -memory 1

# rename the computer and set a static IP address, and add some windowsfeatures
Invoke-Command -VMname "DOMAIN-1"-Credential $credential {
    New-NetIPAddress -IPAddress "10.10.10.10" -InterfaceIndex (Get-NetAdapter).interfaceindex -DefaultGateway "10.10.10.1" -PrefixLength 24
    Install-WindowsFeature -Name "RSAT-AD-Tools","DNS","DHCP","AD-Domain-Services"
    Rename-Computer -NewName "DOMAIN-1" -Restart
}

# create the domain HOME.LAB
Invoke-Command -VMname "DOMAIN-1" -Credential  $credential {
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
    Install-ADDSForest @param
}

# create a domain account to use
# create a domain group to use
# create a GMSA

## setup SERVER-1
# create the VM
# rename the computer
# join the HOME.LAB domain

## setup SERVER-2
# create the VM
# rename the computer
# join the HOME.LAB domain