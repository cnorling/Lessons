<#
The syntax for your PSRC files can get really wonky and difficult to wrap your head around. 
Here is a practical digest on PSRC syntax.

Overview: When you work with JEA, you will primarily work with the four following parmaeters:
    VisibleProviders
    VisibleExternalCommands
    VisibleFunctions
    VisibleCmdlets

All four parameters accept an array comprised of strings and hashtables. 
To keep it simple, we will start with strings. When you only specify a string, you allow all
of the function/cmdlet's parameters, and accept any valid value for those parameters. 
#>

$param = @{
    path = ".\syntax.psrc"
    visiblefunctions = @(
        "set-disk"
    )
    visiblecmdlets = @(
        "get-service"
        "start-service"
        "stop-service"
        "restart-service"
    )
}

New-PSRoleCapabilityFile @param
code ".\syntax.psrc"

<#
However, you do have the ability to get more granular with your functions/cmdlets. 
You can restrict someone from running certain parameters as well!
To do this, you supply a hashtable that contains two key value pairs:

name
    The name of the function/cmdlet you are administrating
parameters
    an array of parameters you want to include
#>

$param = @{
    path = ".\syntax.psrc"
    visiblefunctions = @(
        "set-disk"
    )
    visiblecmdlets = @(
        @{
            name = "get-service"
            parameters = @(
                "name"
                "exclude"
            )
        }
        "start-service"
        "stop-service"
        "restart-service"
    )
}

New-PSRoleCapabilityFile @param
code ".\syntax.psrc"

<#
You can get even MORE granular and administrate what values you can supply to each parameter.
To do this, you supply a hashtable for each parameter that you want to administrate.
The syntax is almost exactly the same as the layer above it.

name
    The name of the parameter you are administrating
validatepattern
    An array of regular expressions you want to accept as valid input for that parameter
#>

$param = @{
    path = ".\syntax.psrc"
    visiblefunctions = @(
        "set-disk"
    )
    visiblecmdlets = @(
        @{
            name = "get-service"
            parameters = @(
                "include"
                "exclude"
                @{
                    name = "name"
                    validatepattern = @(
                        'winmgmt'
                        'winrm'
                        'spooler'
                    )
                }
            )
        }
        "start-service"
        "stop-service"
        "restart-service"
    )
}

New-PSRoleCapabilityFile @param
code ".\syntax.psrc"
