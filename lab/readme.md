# Part 1: Working with hyper-v virtual machines with Powershell

## prerequisites
I have a few things already setup that I won't show in this demo, but they are requirements. You need to:
* enable hyperv as a windows feature and restart your computer
* create a private virtual network switch in hyperv
* setup and structure your files and folders for running virtual machines with hyperv 
* have a CPU that is compatible with running hyper-v
* local admin rights
* have an ISO for whatever operating system you want to work with

## What is hyper-v?
For those of you who don't know, hyper-v is a way to run virtual machines on windows. I come from a Vmware background and I had never used hyper-V. I just had ESXI, so I used that. When I wanted to start doing stuff at home, I didn't feel like spinning up a few other computers to act as ESXI hosts. Creating and maintaining them just sounded like work that I didn't feel like doing. It's really useful to be able to create virtual machines on your home PC and not have to worry about managing an entire virtualized network when you're just dipping your toes in homelab stuff.

When I originally started working with hyper-v, I kept getting stuck on things because I tried to do things the VMware way. Hopefully this presentation will give you some insight into how you can create VMs with HyperV and Powershell.

## organization
I like to organize my stuff in a root folder on the C:\ drive labeled hyperv, then I put three folders inside for Disks, ISOs, and Virtual Machines.

## creating and managing virtual machines
Virtual machine management in hyper-v is signifigantly different from ESXI. You still have the same logical resources like virtual hard disks and virtual machines, but processes like cloning aren't parallel.
If you do work in a VMware environment and want to work with virtual machines, PowerCLI is an excellent module if you haven't used it already.
You don't have templates like you do in ESXI, but you can get the same functionality!

You can break a VM into two basic parts. The virtual hard drive, and a manifest that determines what networks the VM connects to, what virtual hard disk to use, how much memory, and other metadata.

## boot order
If you have worked with hyper-v in the past, you might have run into this "issue" where you create a virtual machine, start it up, and it just stays at the hyper-v boot screen. The default boot order starts with a network adapter, NOT an ISO like you might normally think. You can fix this by changing the boot order before you start the virtual machine.

## the vm isn't dead until the VHDX is nuked
When you delete a virtual machine wether it's via powershell or the GUI, you have only deleted that virtual machine's metadata. The hard disk is still around and will have to be removed as well if you want to completely remove the virtual machine. VMware has an option do that for you when you tell it to. Get-help on Remove-VM will even tell you that it doesn't delete the hard disk.

## virtual hard disks are the cool kid's templates
when you want to clone a virtual machine, you can copy the hard disk, then create a virtual machine and bind it to the hard disk. The copy hard disk operation is what takes up the most time, but with an SSD it should be pretty quick.

## invoke-command on vms
Invoke-command, New-PSSession, and most of the remote machine cmdlets support hyper-v vms. You can authenticate into the target machine as long as you have a local administrative account or a domain account that is an administrator on the target computer. This is really useful for setting up domain controllers and working with vms that aren't on your domain yet.

## snapshots
I don't think I need to talk too much about snapshots, but it is some functionality that you'll want to keep in mind. If you've ever worked with Vmware snapshots, they're really similar. Snapshots play off of eachother in sequentially just like you would have in ESXI. 

# Part 2: Setting up an active directory homelab with Powershell
