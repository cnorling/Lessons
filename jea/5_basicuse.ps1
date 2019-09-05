# create a powershell module
mkdir .\jeamodule
mkdir .\jeamodule\rolecapabilities
New-ModuleManifest -path .\jeamodule\jeamodule.psd1

# create a PSRC and add it to the module
$psrc = @{
    path = ".\jeamodule\rolecapabilities\jea_basic.psrc"
    visiblefunctions = @(
        "set-disk"
    )
    visiblecmdlets = @(
        @{
            name = "get-service"
            parameters = @(
                @{
                    name = "name"
                    validateset = @(
                        "WinRM"
                        "BITS"
                    )
                    validatepattern = @(
                        'B*'
                        'A*'
                        'C*'
                        '(Q*)|(R*)|(S*)'
                    )
                }
            )
        }
        "start-service"
        "stop-service"
        "restart-service"
        "where-object"
    )
}
New-PSRoleCapabilityFile @psrc

# create a PSSC
$pssc = @{
    Path = ".\jeamodule\jea.pssc"
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts\'
    LanguageMode = "NoLanguage"
    SessionType = "RestrictedRemoteServer"
    Full = $true
    RoleDefinitions = @{
        "home.lab\jea" = @{
            RoleCapabilities = "jea_basic"
        }
    }
}
New-PSSessionConfigurationFile @pssc

# copy the module over
$session = New-PSSession -VMName "SERVER-1" -Credential $credential.domainadmin
Copy-Item -ToSession $session -path ".\jeamodule" -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule" -Force

# create a group you reference BEFORE you apply the session configuration
# adding users can come before or after.
invoke-command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    $group = @{
        name = "jea"
        SamAccountName = "jea"
        displayname = "jea"
        groupcategory = "Security"
        groupscope = "Global"
        path = "CN=Users,DC=home,DC=lab"
    }
    new-adgroup @group
    Add-ADGroupMember -Members "bob.saget" -Identity "jea"
}

# apply the session configuration
invoke-command $session {
    Register-PSSessionConfiguration -path "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea.pssc" -name "jea"
}

# try remoting into it
$jeasession = New-PSSession -ComputerName "SERVER-1" -Credential $credential.bob -ConfigurationName "jea"
$jeasession

# jea includes a few commands by default
invoke-command $jeasession {
    get-command
}

# using a command outside your role returns this:
invoke-command $jeasession {
    Add-LocalGroupMember -Group "administrator" -Member "home.lab\bob.saget"
}

# using a parameter or value outside your role looks like this:
invoke-command $jeasession {
    get-service -name "bits" -Include "WinRM"
}
