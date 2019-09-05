<#
The syntax for PSSC files is a lot easier to digest than PSRC files. 
The only strange syntax is the role enumeration, it's similar to PSRC syntax, 
but it only goes one layer deep.
#>

$pssc = @{
    Path = ".\bin\psscsyntax.pssc"
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts\'
    SessionType = "RestrictedRemoteServer"
    Full = $true
    RoleDefinitions = @{
        "home.lab\jeausers" = @{
            RoleCapabilities = @(
                # powershell will search every installed module under system32 and program files
                # for a file under the RoleCapabilities folder named after your role.
                'jea1'
            )
            RoleCapabilityFiles = @(
                # you can be explicit with the rolecapabilities as well by referencing their full path.
                'C:\Program Files\windowspowershell\modules\jea\rolecapabilities\jea2.psrc'
            )
        }
    }
}
New-PSSessionConfigurationFile @pssc
code .\bin\psscsyntax.pssc

<#
Roledefinitions starts as a hashtable containing a key that's named after your endpoint and
a value that's another hashtable. 
The second hashtable contains a keyed list of arrays that you fill with one or more roles, and
a few other optional parameters. Most of the time you'll just use RoleCapabilities.
#>