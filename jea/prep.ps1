<# 
this document is used to prepare a lab environment to demonstrate JEA's capabilities. 
The core requirements for the demonstration are:
* A domain controller
* A destination server

All these virtual machines will be setup with hyper-v.
#>

function New-VMFromTemplate {
    param (
        [String]
        $name,

        [String]
        $vhdxpath,

        [String]
        $vhdxtemplate,

        [String]
        $switch,
        
        [int]
        $memory
    )
    ## verify you're running as admin
    if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $false) {
        throw "you need to run as an administrator for this function to work"
    }

    ## verify vm doesn't exist already
    if ((get-vm $name -ErrorAction SilentlyContinue)) {
        throw "VM already exists"
    }

    ## verify template vhdx exists
    if ((test-path $vhdxtemplate) -eq $false) {
        throw "Target template hard drive is missing"
    }

    ## verify vhdx doesn't exist already
    if ((test-path "$vhdxpath\$name.vhdx") -eq $true) {
        throw "VHDX already exists."
    }

    # copy vhdx
    copy-item -Path $vhdxtemplate -Destination "$vhdxpath\$name.vhdx"

    # create new vm and mount vhdx
    $param = @{
        name = $name
        memorystartupbytes = [int64]$memory * 1GB
        vhdpath = "$vhdxpath\$name.vhdx"
        switchname = $switch
        generation = 2
    }
    $vm = new-vm @param

    # set the boot order
    $bootorder = @(
        Get-VMHardDiskDrive -VM $vm
        Get-VMNetworkAdapter $vm
    )
    Set-VMFirmware -VM $vm -BootOrder $bootorder

    # start the vm
    start-vm -Name $name
}

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
        password = ConvertTo-SecureString -AsPlainText -force -String "Bob's sucky password1"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.username,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.username,$accounts.localadmin.password
    bob = new-object pscredential -argumentlist $accounts.bob.username,$accounts.bob.password
}

## setup DOMAIN-1
# create the VM
New-VMFromTemplate -name "DOMAIN-1" -vhdxpath "C:\hyperv\disks\" -vhdxtemplate "C:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1

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
    safemodeadministratorpassword = $accounts.domainadmin.password
}
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.localadmin {
    Install-ADDSForest @using:param
}

# configure DNS and DHCP for your domain
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    Add-DnsServerPrimaryZone -NetworkID 10.10.10.0/24 -ZoneFile "10.10.10.10.in-addr.arpa.dns"
    Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru
    netsh dhcp add securitygroups
    Add-DHCPServerv4Scope -Name "Employee Scope" -StartRange 10.10.10.10 -EndRange 10.10.10.254 -SubnetMask 255.255.255.0 -State Active -LeaseDuration 1.00:00:00
    Set-DHCPServerv4OptionValue -ScopeID 10.10.10.0 -DnsDomain home.lab -DnsServer 10.10.10.10 -Router 10.10.10.1
    Add-DhcpServerInDC -DnsName "home.lab" -IpAddress 10.10.10.10
}

# create a domain account, a group, and a GMSA to use ... and a KDS root key so you can make GMSAs before the 10 hour convergence cycle
# https://social.technet.microsoft.com/Forums/ie/en-US/82617035-254f-4078-baa2-7b46abb9bb71/newadserviceaccount-key-does-not-exist?forum=winserver8gen
$user = @{
    name = "Bob.Saget"
    SamAccountName  = "Bob.Saget"
    accountpassword = $accounts.bob.password
    enabled = $true
    path = "CN=Users,DC=home,DC=lab"
    changepasswordatlogon = $false
}

invoke-command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    Add-KdsRootKey –EffectiveTime ((get-date).addhours(-10))
    New-ADUser @using:user
}

## setup SERVER-1
# create the VM
New-VMFromTemplate -name "SERVER-1" -vhdxpath "C:\hyperv\disks\" -vhdxtemplate "C:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 2

# sysprep to generate a new sid
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {
    & "C:\windows\system32\sysprep\sysprep.exe" /generalize /shutdown /oobe
}
# if you sysprep, you'll have to reset the local admin password.
# rename the computer
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {
    Rename-Computer -NewName "SERVER-1" -Restart
}
# join the domain
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {
    Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart
}
