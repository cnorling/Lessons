# Pissing everyone off with JEA *(Just Enough Administration)*

## Subjects
* What is JEA
* 


what is jea
    acronym
what are some use cases
    When your CISO is pissed off and hates powershell, you can offer JEA as an alternative to please C levels
    when you have a task that needs local admin but you're worried about security
    root of it is it's a security utility.
    powershell is used in a large number of malicious attacks today. Using JEA can give you better posture to deal with these kinds of threats.
What are some prerequisites to working with JEA?
    basic psremoting knowledge
    basic module creation knowledge
    splatting
how does it work
    get into how pssessions work
    show pre-registered pssession configurations    
what cmdlets do you use to manage JEA
    get-pssessionconfiguration
    register-pssessionconfiugration
    new-psrolecapabilityfile
    enter-pssession
Define a role
    manually creating the file
    splatting
create a powershell module
    create the root folder
    create the psd1
    create the psm1
    create the keyword folder
    add the pssessionconfiguration file to the keyword folder
Create a session configuration
    create it
    associate it with the role
Common mistakes
    defining a cmdlet as a role or vice versa
Apply the session configuration to a computer
    move the new module over to the computer you want to manage
    call register-pssessionconfiguration
A practical example of how I use it in my environment
    With DSC to issue certificates and call update-dscconfiguration

## FAQ

### What is JEA?
JEA is short for Just Enough Administration. It is a utility to administer who can use powershell, and where.

### What are some use-cases for JEA?
* You want to give someone limited administrative access to a server or servers.
* You want to assign roles to users and give them the tools they need to do their jobs.
* You want to limit what a user can do with powershell under an administrative context.

### How hard is it to setup JEA?
Honestly, setting up JEA is preetty easy. Configuring what commands a person can run under what roles is what takes the most time.

### What ports and protocols does JEA use?
JEA uses the same ports and protocols as WinRM (5985,5986)

### File extensions?
There are a couple powershell files that are used for JEA?
|Extension|Name|Purpose|
|.psrc|PS Role Capability|Creates "Roles" that decide what commands a user can use|
|.pssc|PS Session Config|Creates the session the user connects to|

### How do I use it?

### How do I use it in scale?
Tools like DSC (Desired State Configuration) can help you deploy configurations and sessions, but DSC is not needed.
The core requirements for deploying JEA are as follows:

#### Have some means to create session configurations on the computers you want to manage with JEA
This can be something like a payload added to a VMware template/base image on a virtual machine. It can also be an element in your CI|CD pipeline. Remember that you can create a PS session configuration off domain, but you need to be on domain to associate those session configurations with a domain user or group.

#### Have some means to distribute and update powershell modules to the computers you want to manage with JEA
This step is more complicated. You can add a payload just like the previous step, but you need a way to update, add, and remove the session configurations. Publishing your modules to a nuget based powershell repository can make it easier to distribute packages, but it banks off of you already having something like that in your environment. Keeping the roles up-to-date and consistent is just as important as first time setup is. If you don't have a way to quickly make changes to roles everywhere, your developers and system administrators are going to hate you. Hence the title.

### What risks are there associated with JEA?
There are certain commands that you rarely, if ever want to authorize with JEA. Below are some examples and reasons why you would not want them in your environment
|Command|Risks|
|-------|-----|
|Invoke-Expression|Allows you to run any powershell command.|
|Start-Process|Allows you to start foreign processes including malware executables.|
|New-Service|Allows you to create a service that can execute malware.|
|Invoke-WmiMethod|Incredibly broad scope allows system level changes to anything WMI related on the target computer.|
|Invoke-Command|Allows you to run commands outside your current scope.|
|New-ScheduledTask|Establishes a path to elevate your context to local administrator|
|Add-localgroupmember|Allows you to elevate another account as a local administrator, bypassing JEA.|

There are other risks to consider. If you are deploying JEA on a domain controller, consider that a local admin user has access to domain admin context. Understanding how JEA works from top to bottom helps you understand what the risks are.
