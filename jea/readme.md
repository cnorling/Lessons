# Pissing everyone off with JEA *(Just Enough Administration)*

## FAQ

### What is JEA?
JEA is short for Just Enough Administration. It is a utility to administer who can use powershell, and what commands you can use.

### What are some use-cases for JEA?
* You want to give someone limited administrative access to a server or servers.
* You want to assign roles to users and give them the tools they need to do their jobs.
* You want to limit what a user can do with remote powershell sessions under an administrative context.

### How hard is it to setup JEA?
Honestly, setting up JEA is preetty easy. Configuring what commands a person can run under what roles is what takes the most time.

### File extensions?
There are a couple powershell files that are used for JEA.

|Extension|Name|Purpose|
|---------|----|-------|
|.psrc|PS Role Capability|Creates "Roles" that decide what commands a user can use|
|.pssc|PS Session Config|Creates the session the user connects to|

### How do I use it in scale?
Tools like DSC (Desired State Configuration) can help you deploy configurations and sessions, but DSC is not needed.
The core requirements for deploying JEA are as follows:

#### Have some means to create session configurations on the computers you want to manage with JEA
This can be something like a payload added to a VMware template/base image on a virtual machine. It can also be an element in your CI|CD pipeline. Remember that you can create a PSSC off domain, but you need to be on domain to associate those session configurations with a domain user or group.

#### Have some means to distribute and update powershell modules to the computers you want to manage with JEA
This step is more complicated. You can add a payload just like the previous step, but you need a way to update, add, and remove the role capabilities. Publishing your modules to a nuget feed (think the powershell gallery)can make it easier to distribute packages, but it banks off of you already having something like that in your environment. Keeping the roles up-to-date and consistent is just as important as first time setup is. If you don't have a way to quickly make changes to roles everywhere, your developers and system administrators are going to hate you.

### What risks are there associated with JEA?
There are certain commands that you rarely, if ever want to authorize with JEA. Below are some examples and reasons why you would not want them in your environment
|Command|Risks|
|-------|-----|
|Invoke-Expression|Allows you to run any powershell command.|
|Start-Process|Allows you to start foreign processes including malware executables.|
|New-Service|Allows you to create a service that can execute malware.|
|Invoke-WmiMethod|Incredibly broad scope allows system level changes to anything WMI related on the target computer.|
|Invoke-CIMMethod|Incredibly broad scope allows system level changes to anything CIM related on the target computer.|
|Invoke-Command|Allows you to run commands outside your current scope.|
|New-ScheduledTask|Establishes a path to execute other commands outside of JEA's scope, which you can then use to escalate your permissions.|
|Add-localgroupmember|Allows you to elevate another account as a local administrator, bypassing JEA.|

There are other risks to consider. If you are deploying JEA on a domain controller, consider that a local admin user has access to domain admin context. Understanding how JEA works from top to bottom helps you understand what the risks are.
With that said, what other commands may allow you to get around JEA?

### I'm never going to use this in my environment.
You might not, but i'm hoping this lesson will at least give you more background on how powershell remoting works. If it ever comes up in a discussion, or someone else suggests JEA, you can chime in. Just because you don't use it now doesn't mean you won't encounter it in the future!
