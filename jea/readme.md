# Pissing everyone off with JEA *(Just Enough Administration)*

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

### How do I use it?

### How do I use it in scale?

### In an enterprise environment, what are some base requirements you have for configuring and deploying JEA at scale?

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

Additionally, there are other risks to consider. If you are deploying JEA on a domain controller, consider that a local admin user has access to domain admin context.
