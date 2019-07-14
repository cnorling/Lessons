# define a session by running a command (as local admin) that points to a .pssc file

# start by creating the pssessionconfiguration file
New-PSSessionConfigurationFile -Path .\sessionconfiguration.psrc

<#
You have a couple options out of the box

Here are the basic ones

TranscriptDirectory
    JEA saves transcripts of the commands that are used when you login with JEA

RunAsVirtualAccount
ScriptsToProcess
RoleDefinitions
#>