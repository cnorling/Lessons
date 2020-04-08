# setting up from scratch. To start, we'll need some kind of virtual machine template.
# I use server core because I'm cool

# first we create a virtual machine
$memory = [int64]2 * 1GB
$disk = [int64]100 * 1GB
$name = "TEMPLATE"
$param = @{
    name = $name
    memorystartupbytes = $memory
    newvhdpath = "C:\hyperv\disks\$name.vhdx"
    newvhdsizebytes = $disk
    switchname = "Lab"
    generation = 2
}
$vm = new-vm @param
$vm

# then we create a cd drive and mount the iso
$vm | Add-VMDvdDrive -Path "C:\hyperv\iso\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

# then we set the boot order
$bootorder = @(
    Get-VMHardDiskDrive -VM $vm
    Get-VMDvdDrive -VM $vm
    Get-VMNetworkAdapter $vm
)
Set-VMFirmware -VM $vm -BootOrder $bootorder

# start the vm
start-vm -Name $name

# then we setup the virtual machine, restart, set a password, turn it off again, then delete the virtual machine.
get-vm "template" | remove-vm

# the vm is gone, but the hard disk of that VM is still around. We can use that as our template!
Get-Item "C:\hyperv\disks\TEMPLATE.vhdx" | Copy-Item -Destination "C:\hyperv\disks\NEWVM.vhdx"

# now we need to create a vm and associate it's metadata with that hard disk
$name = "NEWVM"

# verify vm doesn't exist already
if ((get-vm $name -ErrorAction SilentlyContinue)) {
    throw "VM already exists"
}

# create new vm and mount vhdx
$param = @{
    name = $name
    memorystartupbytes = [int64]2 * 1GB
    vhdpath = "C:\hyperv\disks\$name.vhdx"
    switchname = "lab"
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

# you now have a working virtual machine! you can even use invoke-command on it to manage it without a domain.
# first you setup some credentials
$accounts = @{
    domainadmin = @{
        username = "home.lab\administrator"
        password = ConvertTo-SecureString -AsPlainText -Force -String "Domain!"
    }
    localadmin = @{
        username = "administrator"
        password = ConvertTo-SecureString -AsPlainText -force -String "Homelab!"
    }
}
$credential = @{
    domainadmin = new-object pscredential -argumentlist $accounts.domainadmin.username,$accounts.domainadmin.password
    localadmin = new-object pscredential -argumentlist $accounts.localadmin.username,$accounts.localadmin.password
}

# then you call invoke-command!
Invoke-Command -VMName "NEWVM" -Credential $credential.localadmin {
    $env:computername
}

# snapshots
get-command "*vmsnapshot*"

# you can take snapshots with checkpoint-vm
Checkpoint-VM -Name "NEWVM" -SnapshotName "snip"
Checkpoint-VM -Name "NEWVM" -SnapshotName "snap"

# and revert with restore-vmshapshot
Get-VMSnapshot -VMName "NEWVM" -Name "snip" | Restore-VMSnapshot