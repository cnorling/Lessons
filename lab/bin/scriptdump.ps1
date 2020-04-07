function New-VMTemplate {
    param (
        [String]
        $name,

        [String]
        $switch,
        
        [String]
        $iso,
        
        [String]
        $memoryCapacityGB,

        [String]
        $diskCapacityGB
    )
    # verify you're running as admin
    if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $false) {
        throw "you need to run as an administrator for this function to work"
    }
    # verify iso exists
    if ((test-path $iso) -eq $false) {
        throw "ISO does not exist"
    }
    # verify switch exists
    if (!(get-vmswitch -name $switch)) {
        throw "the referenced switch does not exist"
    }
    
    # create the vm
    $memory = [int64]$memoryCapacityGB * 1GB
    $disk = [int64]$diskCapacityGB * 1GB
    $param = @{
        name = $name
        memorystartupbytes = $memory
        newvhdpath = "D:\hyperv\disks\$name.vhdx"
        newvhdsizebytes = $disk
        switchname = $switch
        generation = 2
    }
    $vm = new-vm @param

    # create the cd drive and mount the iso
    $vm | Add-VMDvdDrive -Path $iso
    
    # set the boot order
    $bootorder = @(
        Get-VMHardDiskDrive -VM $vm
        Get-VMDvdDrive -VM $vm
        Get-VMNetworkAdapter $vm
    )
    Set-VMFirmware -VM $vm -BootOrder $bootorder

    # start the vm
    start-vm -Name $name
}




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
    pdqhelper = @{
        username = "home.lab\pdqhelper"
        password = ConvertTo-SecureString -AsPlainText -force -String "PDQRocks!"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.username,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.username,$accounts.localadmin.password
    pdqhelper = new-object pscredential -argumentlist $accounts.pdqhelper.username,$accounts.pdqhelper.password
}

## setup DOMAIN-1
# create the VM
New-VMFromTemplate -name "DOMAIN-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1
# rename the computer, set a static IP address, and add some windowsfeatures
Invoke-Command -VMname "DOMAIN-1"-Credential $credential.localadmin {
    New-NetIPAddress -IPAddress "10.10.11.10" -InterfaceIndex (Get-NetAdapter "Ethernet 2").interfaceindex -DefaultGateway "10.10.11.1" -PrefixLength 24
    Install-WindowsFeature -Name "RSAT-AD-Tools","DNS","DHCP","AD-Domain-Services" -IncludeManagementTools
    Rename-Computer -NewName "DOMAIN-1" -Restart
}
Add-VMNetworkAdapter -VMName "DOMAIN-1" -SwitchName "lab"

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
    Add-DnsServerPrimaryZone -NetworkID 10.10.11.0/24 -ZoneFile "11.10.10.in-addr.arpa.dns"
    Add-DnsServerForwarder -IPAddress 10.10.10.1 -PassThru
}
Invoke-Command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    #netsh dhcp add securitygroups
    #Restart-Service dhcpserver
    #Add-DhcpServerInDC -DnsName "domain-1.home.lab" -IPAddress 10.10.11.10
    #Add-DHCPServerv4Scope -Name "homelab" -StartRange 10.10.11.10 -EndRange 10.10.11.254 -SubnetMask 255.255.255.0 -State "Active" -LeaseDuration 1.00:00:00
    Set-DHCPServerv4OptionValue -ScopeID 10.10.11.0 -DnsServer 10.10.11.10 -Router 10.10.11.1
}

# create a domain account, a group, and a GMSA to use ... and a KDS root key so you can make GMSAs before the 10 hour convergence cycle
# https://social.technet.microsoft.com/Forums/ie/en-US/82617035-254f-4078-baa2-7b46abb9bb71/newadserviceaccount-key-does-not-exist?forum=winserver8gen
$users = @(
    @{
        name = "Wendy"
        SamAccountName  = "Wendy"
        accountpassword = $accounts.pdqhelper.password
        enabled = $true
        path = "CN=Users,DC=home,DC=lab"
        changepasswordatlogon = $false
    }
    @{
        name = "Ronald"
        SamAccountName  = "Ronald"
        accountpassword = $accounts.pdqhelper.password
        enabled = $true
        path = "CN=Users,DC=home,DC=lab"
        changepasswordatlogon = $false
    }
    @{
        name = "Col sanders"
        SamAccountName  = "sanders"
        accountpassword = $accounts.pdqhelper.password
        enabled = $true
        path = "CN=Users,DC=home,DC=lab"
        changepasswordatlogon = $false
    }    
    @{
        name = "pdqhelper"
        SamAccountName  = "pdqhelper"
        accountpassword = $accounts.pdqhelper.password
        enabled = $true
        path = "CN=Users,DC=home,DC=lab"
        changepasswordatlogon = $false
    }     
)

invoke-command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    #Add-KdsRootKey –EffectiveTime ((get-date).addhours(-10))
    foreach ($user in $using:users) {
        new-aduser @user
    }
    Add-ADGroupMember -Members (get-aduser -filter 'name -like "pdqhelper"') -Identity "Domain Admins"
}

## setup ROUTER-1
# create the VM
New-VMFromTemplate -name "ROUTER-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1

# sysprep to generate a new sid
invoke-command -VMName "ROUTER-1" -Credential $credential.localadmin {
    start-process -wait -FilePath "C:\windows\system32\sysprep\sysprep.exe" -ArgumentList "/generalize /reboot /oobe"
}
# if you sysprep, you'll have to reset the local admin password.
# rename the computer
invoke-command -VMName "ROUTER-1" -Credential $credential.localadmin {
    Rename-Computer -NewName "ROUTER-1" -Restart
}
# add a second nic to route to
Add-VMNetworkAdapter -VMName "ROUTER-1" -SwitchName "lab"
invoke-command -VMName "ROUTER-1" -Credential $credential.localadmin {
    Rename-NetAdapter -name "Ethernet" -NewName "DOMAIN"
    Rename-NetAdapter -name "Ethernet 2" -NewName "HOME"
    New-NetIPAddress -InterfaceAlias "DOMAIN" -IPAddress 10.10.11.1 -PrefixLength 24
    New-NetIPAddress -InterfaceAlias "HOME" -IPAddress 10.10.10.100 -PrefixLength 24
    Set-DnsClientServerAddress -InterfaceAlias "DOMAIN" -ServerAddresses 10.10.11.10,10.10.10.1
    Disable-NetAdapterBinding -Name "DOMAIN","HOME" -ComponentID ms_tcpip6
    Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
    Install-WindowsFeature Routing -IncludeAllSubFeature -IncludeManagementTools
    Restart-Computer -force
}
invoke-command -VMName "ROUTER-1" -Credential $credential.localadmin {
    #Install-RemoteAccess -VpnType Vpn
    netsh routing ip nat add interface HOME
    netsh routing ip nat add interface DOMAIN
    netsh routing ip nat set interface HOME mode=full
    netsh routing ip nat set interface DOMAIN mode=full
}

## setup PDQDEP-1 and PDQINV-1
# create the VMs
New-VMFromTemplate -name "PDQ-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-desktop-template.vhdx" -switch "domain" -memory 4

# sysprep to generate a new sid
invoke-command -VMName "PDQ-1" -Credential $credential.localadmin {start-process -wait -FilePath "C:\windows\system32\sysprep\sysprep.exe" -ArgumentList "/generalize /reboot /oobe"}

# rename the computer
invoke-command -VMName "PDQ-1" -Credential $credential.localadmin {Rename-Computer -NewName "PDQ-1" -Restart}

# join the domain
invoke-command -VMName "PDQ-1" -Credential $credential.localadmin {Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart}

# add a second network adapter
#Add-VMNetworkAdapter -VMName "PDQDEP-1" -SwitchName "lab"

# copy out pdq deploy executable and install
$session = New-PSSession -VMname "PDQ-1" -Credential $credential.domainadmin
copy-item -ToSession $session -Path "D:\iso\PDQDeploy.17.2.0.0.exe" -Destination "C:\pdqdeploy.exe"
copy-item -ToSession $session -Path "D:\iso\PDQInventory.17.1.0.0.exe" -Destination "C:\pdqinventory.exe"
copy-item -ToSession $session -Path "D:\iso\pdqi.txt" -Destination "C:\pdqi.txt"
copy-item -ToSession $session -Path "D:\iso\pdqd.txt" -Destination "C:\pdqd.txt"


invoke-command $session {
    Start-Process -FilePath "C:\pdqdeploy.exe" -ArgumentList '/s' -Wait
    Start-Process -FilePath "C:\pdqinventory.exe" -ArgumentList '/s' -Wait
}

## setup SERVER-1-3
# create the VMs
New-VMFromTemplate -name "SERVER-1" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1
New-VMFromTemplate -name "SERVER-2" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1
New-VMFromTemplate -name "SERVER-3" -vhdxpath "D:\hyperv\disks\" -vhdxtemplate "D:\hyperv\disks\2016-core-template.vhdx" -switch "domain" -memory 1

# sysprep to generate a new sid
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {& "C:\windows\system32\sysprep\sysprep.exe" /generalize /reboot /oobe}
invoke-command -VMName "SERVER-2" -Credential $credential.localadmin {& "C:\windows\system32\sysprep\sysprep.exe" /generalize /reboot /oobe}
invoke-command -VMName "SERVER-3" -Credential $credential.localadmin {& "C:\windows\system32\sysprep\sysprep.exe" /generalize /reboot /oobe}

# rename the computer
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {Rename-Computer -NewName "SERVER-1" -Restart}
invoke-command -VMName "SERVER-2" -Credential $credential.localadmin {Rename-Computer -NewName "SERVER-2" -Restart}   
invoke-command -VMName "SERVER-3" -Credential $credential.localadmin {Rename-Computer -NewName "SERVER-3" -Restart}

# join the domain
invoke-command -VMName "SERVER-1" -Credential $credential.localadmin {Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart}
invoke-command -VMName "SERVER-2" -Credential $credential.localadmin {Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart}
invoke-command -VMName "SERVER-3" -Credential $credential.localadmin {Add-Computer -domainname "home.lab" -credential $using:credential.domainadmin -Restart}

# allow inbound icmp traffic
$servers = "SERVER-1","SERVER-2","SERVER-3","PDQDEP-1","PDQINV-1","DOMAIN-1"
foreach ($server in $servers) {
    invoke-command -VMName $server -Credential $credential.domainadmin {Get-NetFirewallRule FPS-ICMP4-ERQ-in | Enable-NetFirewallRule}
}

# change ACL on IPC and admin shares
$servers = "SERVER-1","SERVER-2","SERVER-3","PDQDEP-1","PDQINV-1","DOMAIN-1"
foreach ($server in $servers) {
    invoke-command -VMName $server -Credential $credential.domainadmin {
        Get-NetFirewallRule FPS-ICMP4-ERQ-in | Enable-NetFirewallRule
        Get-NetFirewallRule FPS-SMB-IN-TCP | Enable-NetFirewallRule
    }
}

# install 7-Zip
$servers = "SERVER-1","SERVER-3"
foreach ($server in $servers) {
    $7zsession = New-PSSession -VMname $server -Credential $credential.domainadmin
    copy-item -ToSession $7zsession -Path "D:\iso\7zip.msi" -Destination "C:\7zip.msi"
    invoke-command $7zsession {
        Start-Process -FilePath "C:\windows\system32\msiexec.exe" -ArgumentList '/i C:\7zip.msi /quiet /norestart'
    }    
}