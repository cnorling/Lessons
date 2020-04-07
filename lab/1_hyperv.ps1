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
$vhdxtemplate = "C:\hyperv\disks\"
$vhdxpath = "C:\hyperv\disks"
$memory = 2

## verify vm doesn't exist already
if ((get-vm $name -ErrorAction SilentlyContinue)) {
    throw "VM already exists"
}

# create new vm and mount vhdx
$param = @{
    name = $name
    memorystartupbytes = [int64]$memory * 1GB
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