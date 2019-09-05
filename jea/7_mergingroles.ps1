# role definitions can use a number of role capabilities. 
# As long as they are in a valid module path, they will import.

$psrc = @{
    path = ".\jeamodule\rolecapabilities\jea_advanced.psrc"
    visiblefunctions = @(
        "set-disk"
        "reset-physicaldisk"
        "resize-virtualdisk"
        "repair-virtualdisk"
        "initialize-disk"
    )
}
New-PSRoleCapabilityFile @psrc

$pssc = @{
    Path = ".\jeamodule\jea_basic.pssc"
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts\'
    LanguageMode = "FullLanguage"
    SessionType = "RestrictedRemoteServer"
    Full = $true
    RoleDefinitions = @{
        "home.lab\jea_basic" = @{
            RoleCapabilities = @(
                "jea_basic"
                "jea_advanced"
            )
        }
    }
}
New-PSSessionConfigurationFile @pssc

# copy the new role and session out
Copy-Item -ToSession $session -path ".\jeamodule\jea_basic.pssc" -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea_basic.pssc" -Force
Copy-Item -ToSession $session -path ".\jeamodule\rolecapabilities\jea_advanced.psrc" -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule\rolecapabilities\jea_advanced.psrc" -Force
invoke-command $jea {
    get-command
}
# the new commands won't show up until we re-establish the powershell session

$jea = New-PSSession -ComputerName "SERVER-1" -Credential $credential.bob -ConfigurationName "jea_basic"
invoke-command $jea {
    get-command
}

# you can have more than one defined role in one JEA endpoint.
# create a new group and "promote" bob to dns admin
invoke-command -VMname "DOMAIN-1" -Credential $credential.domainadmin {
    $group = @{
        name = "dns_admins"
        SamAccountName = "dns_admins"
        displayname = "dns_admins"
        groupcategory = "Security"
        groupscope = "Global"
        path = "CN=Users,DC=home,DC=lab"
    }
    new-adgroup @group
    Add-ADGroupMember -Members "bob.saget" -Identity "dns_admins"
}

# add the new role to the PSSC and publish a new PSRC
$pssc = @{
    Path = ".\jeamodule\jea_basic.pssc"
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts\'
    LanguageMode = "FullLanguage"
    SessionType = "RestrictedRemoteServer"
    Full = $true
    RoleDefinitions = @{
        "home.lab\jea_basic" = @{
            RoleCapabilities = @(
                "jea_basic"
                "jea_advanced"
            )
        }
        "home.lab\dns_admins" = @{
            rolecapabilities = @(
                "dns_admins"
            )
        }
    }
}
$psrc = @{
    path = ".\jeamodule\rolecapabilities\jea_advanced.psrc"
    visiblefunctions = @(
        "Get-DnsServerZone"
        "Get-DnsServer"
        "Get-DnsClient"
        "Clear-DnsClientCache"
        "Enable-DnsServerPolicy"
        "test-path"
    )
    visibleproviders = @(
        "environment"
    )
}
New-PSSessionConfigurationFile @pssc
New-PSRoleCapabilityFile @psrc
invoke-command $session {
    Remove-Item -recurse -path "C:\Program Files\WindowsPowerShell\Modules\jeamodule"
}
Copy-Item -ToSession $session -recurse -path ".\jeamodule" -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule" -Force

invoke-command $session {
    unregister-pssessionconfiguration -name "jea_basic"
    register-pssessionconfiguration -name "jea_basic" -Path "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea_basic.pssc"
    restart-service -name winrm
}

$jea = New-PSSession -ComputerName "SERVER-1" -Credential $credential.bob -ConfigurationName "jea_basic"

# the commands from two different roles are now available!
invoke-command $jea {
    get-command
}