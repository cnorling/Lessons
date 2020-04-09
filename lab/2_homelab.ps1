# we're going to take some earlier content and bind it into functions we can use to create virtual machines
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

## credential setup
$accounts = @{
    # create a credential object for your domain admin creds
    domainadmin = @{
        username = "home.lab\administrator"
        password = ConvertTo-SecureString -AsPlainText -Force -String "Domain!"
    }
    # create a credential object for your local admin password (to setup all 6 machines)
    localadmin = @{
        username = "administrator"
        password = ConvertTo-SecureString -AsPlainText -force -String "Homelab!"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.username,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.username,$accounts.localadmin.password
}

## setup DOMAIN-1
# create the VM
New-VMFromTemplate -name "DOMAIN-1" -vhdxpath "C:\hyperv\disks\" -vhdxtemplate "C:\hyperv\disks\2016-core-template.vhdx" -switch "lab" -memory 1

# sysprep the vm

# rename the vm, set a static IP address, and add some windowsfeatures
Invoke-Command -VMname "DOMAIN-1"-Credential $credential.localadmin {
    New-NetIPAddress -IPAddress "10.10.11.10" -InterfaceIndex (Get-NetAdapter "Ethernet 2").interfaceindex -DefaultGateway "10.10.11.1" -PrefixLength 24
    Install-WindowsFeature -Name "RSAT-AD-Tools","DNS","DHCP","AD-Domain-Services" -IncludeManagementTools
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

# you have to wait about 5 minutes for GPOs to apply to the domain controller.
# then you have to set a new password to authenticate against the domain

# configure DNS and DHCP for your domain
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    Add-DnsServerPrimaryZone -NetworkID 10.10.11.0/24 -ZoneFile "11.10.10.in-addr.arpa.dns"
}
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    netsh dhcp add securitygroups
    Restart-Service dhcpserver
    Add-DhcpServerInDC -DnsName "domain-1.home.lab" -IPAddress 10.10.11.10
    Add-DHCPServerv4Scope -Name "homelab" -StartRange 10.10.11.10 -EndRange 10.10.11.254 -SubnetMask 255.255.255.0 -State "Active" -LeaseDuration 1.00:00:00
    Set-DHCPServerv4OptionValue -ScopeID 10.10.11.0 -DnsServer 10.10.11.10 -Router 10.10.11.1
}

# setup another server to use the domain
# create the VMs
New-VMFromTemplate -name "SERVER-1" -vhdxpath "C:\hyperv\disks\" -vhdxtemplate "C:\hyperv\disks\2016-core-template.vhdx" -switch "lab" -memory 1

# sysprep to generate a new sid
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {& "C:\windows\system32\sysprep\sysprep.exe" /generalize /reboot /oobe}

# rename the computer
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {Rename-Computer -NewName "SERVER-1" -Restart}

# join the domain
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart}

# allow inbound icmp traffic
invoke-command -VMName "SERVER-1" -Credential $credential.domainadmin {Get-NetFirewallRule FPS-ICMP4-ERQ-in | Enable-NetFirewallRule}

# let's test it out by double hopping from SERVER-1 to DOMAIN-1 and reading the hostname
invoke-command -VMName "SERVER-1" -Credential $credential.domainadmin {
    Invoke-Command "DOMAIN-1" -Credential $using:credential.domainadmin {
        $env:computername
    }
}