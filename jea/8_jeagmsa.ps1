# If you need to access domain based resources, you can run JEA as a GMSA.
# first we create the GMSA and allow the server to get the password
invoke-command -VMName "DOMAIN-1" -Credential $credential.domainadmin {
    $gmsa = @{
        name = "JEA_GMSA"
        dnshostname = "JEA_GMSA.home.lab"
        PrincipalsAllowedToRetrieveManagedPassword = "SERVER-1$"
    }
    New-ADServiceAccount @gmsa
    mkdir C:\smbshare
    remove-smbshare -name "jeasmbshare"
    New-SmbShare -name "JEASmbShare" -path "C:\smbshare" -FullAccess "home.lab\JEA_GMSA$"
}

# then we configure the PSSC to use the GMSA
$pssc = @{
    Path = ".\jeamodule\jea_basic.pssc"
    TranscriptDirectory = 'C:\Transcripts\'
    LanguageMode = "FullLanguage"
    SessionType = "RestrictedRemoteServer"
    GroupManagedServiceAccount = "home.lab\JEA_GMSA"
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

invoke-command $session {
    Remove-Item -recurse -path "C:\Program Files\WindowsPowerShell\Modules\jeamodule"
}
Copy-Item -ToSession $session -recurse -path ".\jeamodule" -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule" -Force

invoke-command $session {
    unregister-pssessionconfiguration -name "jea_basic"
    register-pssessionconfiguration -name "jea_basic" -Path "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea_basic.pssc"
    restart-service -name winrm
}

$jea = New-PSSession -vmname "SERVER-1" -Credential $credential.bob -ConfigurationName "jea_basic"
invoke-command $jea {
    $env:username
}