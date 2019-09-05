<#
PSRC files, short for Powershell Role Capabilities are what you use to define what functions,
cmdlets, providers, and aliases as user has access to when they use JEA. 
This page goes over how to generate these files, and each parameter's function.
PSRC files are the WHAT and PSSC files are the WHO

Microsoft's documentation on this subject is excellent and worth a read:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-psrolecapabilityfile?view=powershell-5.1
#>

# start by creating a pssessionconfiguration file, then edit it.
New-PSRoleCapabilityFile -Path ".\bin\manualrole.psrc"
code ".\bin\manualrole.psrc"

<#
Most of the below items all accept an array of hashtables, or an array of strings unless otherwise noted.
We will go into the syntax later.

ModulesToImport
    These are the modules you want to import when you use a JEA endpoint. ALL commands in the imported
    modules are visible when you include them in this field. 

VisibleAliases
    By default, aliases are not visible when you use a JEA endpoint. You can make them visible by
    adding them to this array.You can also define your own aliases by using AliasADefinitions

VisibleCmdlets
    The cmdlets you want to grant access to.

VisibleFunctions
    The functions you want to grant access to.

VisibleExternalCommands
    These are executables that you want to grant access to. Think things like ipconfig, nslookup, net, vb, etc... 

VisibleProviders
    These are the providers that you want to grant access to.
    You can get a list of the providers powershell ships with by running Get-PSProvider

ScriptsToProcess
    When you login, any scripts that are present in this array will be executed. You can 
    reference a locally saved script that's usually distributed with the module you ship
    your PSRC files with, or just something saved somewhere.

AliasADefinitions
    lets you define additional aliases that aren't in powershell by default.

FunctionDefinitions
    You can define your own functions! You also don't have to add all the cmdlets the function
    uses either!
    
VariableDefinitions
    You can initialize your own variables if you like.

environmentvariaibles
    you can intialize your own environment variables as well.

FormatsToProcess
TypesToProcess
AssembliesToLoad
    never used any of these.
#>

# a better way is to define the role, then create the file by splatting.
$roleparameters = @{
    path = ".\bin\splatrole.psrc"
    visiblefunctions = @(
        
    )
    visiblecmdlets = @(

    )
    VisibleProviders = @(
        "registry"
        "alias"
        "environment"
        "filesystem"
        "Function"
        "variable"
        "certificate"
    )
    VisibleExternalCommands = @(
        "ipconfig"
        "nslookup"
    )
}
New-PSRoleCapabilityFile @roleparameters
code ".\bin\splatrole.psrc"
