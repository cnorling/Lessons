# define a role by creating a file, then editing it.
New-PSRoleCapabilityFile -Path ".\jea\manualrole.psrc"
code ".\jea\manualrole.psrc"
<#
This way sucks for numerous reasons. The syntax is hard, there's no error checking, and the files themselves are illegible
There has to be a better way!
#>

# define the role, then create the file by splatting.
$roleparameters = @{
    path = ".\jea\splatrole.psrc"
    SessionType = "RestrictedRemoteServer"
    transcriptdirectory = "C:\transcripts"
    runasvirtualaccount = "$true"
    visiblefunctions = @(
        
    )
    visiblecmdlets = @(

    )
}
New-PSRoleCapabilityFile @roleparameters
<#
check who knows splatting
You can run commands by creating a hashtable of parameter names and their values, then execute the command with the variable as the parameters.
#>
