<#
PSSC files, short for Powershell Session Configuration files are what you use to create an endpoint you
can remote into with powershell. They allow you to associate users and groups with the PSRC roles you 
create as well as a few other settings. This page goes over how to generate these files, and each parameter's function.

Microsoft's documentation on this subject is excellent and worth a read:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-pssessionconfigurationfile?view=powershell-5.1
#>

# start by creating a pssessionconfiguration file.
New-PSSessionConfigurationFile -Path .\sessionconfiguration.pssc
code .\sessionconfiguration.pssc

<#
TranscriptDirectory
    JEA saves transcripts of the commands that are used when you login with JEA

RunAsVirtualAccount
    A LOCAl virtual account that is created when you login with JEA, and closed when you
    log out. It makes sense to only create local admin accounts when they're in use,
    log what they do, then destory them when they are done. You would set this to false if
    the JEA endpoint you are working with needs access to domain based resources. In that
    case, you would be logging in as a GMSA.

RoleDefinitions
    This is where you enumerate which groups are associated with what roles.
    A domain group can be associated with one or more roles
#>

#You can also get more advanced options by running this:
New-PSSessionConfigurationFile -Path .\fullsessionconfiguration.pssc -Full
code .\fullsessionconfiguration.pssc

<#
RunAsVirtualAccountGroups
    The LOCAL groups your virtual account is a member of when you login with JEA
    
MountUserDrive
    lets you mount a drive that persists across sessions. The drive is created under
    $env:LOCALAPPDATA\Microsoft\Windows\PowerShell\DriveRoots\

UserDriveMaximumSize
    If you mount a user drive, you can set how large you want the user drive to be.
    The default if not specified is 50MB

GroupManagedServiceAccount
    If you disable RunAsVirtualAccount, you need to specify a GMSA to run as. This is useful when you
    need a JEA endpoint that needs to interact with domain based resources that are outside of the
    local administrative context. You will be able to authenticate against SMB shares and access any
    other elements that the GMSA is ACl'd against (provided the role has access to the appropriate
    cmdlets and provider.) 

RequiredGroups
    If the default role definitions aren't granular enough, you can add requiredgroups to determine who
    can use the PSSC. 

LanguageMode
    lets you set the languagemode for your session. The default mode is NO LANGUAGE
    https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes?view=powershell-5.1

ExecutionPolicy
    Self-explanatory.

PowerShellVersion
    Self-explanatory, but pretty interesting.

All the below parameters are present when you generate a PSRC file, and do the same thing but for all
roles definied in the session configuration.
    ModulesToImport
    VisibleAliases
    VisibleCmdlets
    VisibleFunctions
    VisibleExternalCommands
    VisibleProviders
    AliasDefinitions
    FunctionDefinitions
    VariableDefinitions
    EnvironmentVariables
    TypesToProcess
    FormatsToProcess
    AssembliesToLoad
#>

# You can also test PSSC files by running Test-PSSessionConfigurationFile
Test-PSSessionConfigurationFile -path .\botchedsessionconfiguration.pssc

# After you've used a PSSC file, you can delete it with no consequence.
