# you can use the pipeline even in no language mode
invoke-command $jeasession {
    get-service bits | restart-service
}

# but you can't use language like IF/ELSE/TRY/CATCH/FINALLY
invoke-command $jeasession {
    if (1 + 1 -eq 2) {
        get-service
    }
}

# if you change the language mode to restricted or full language mode, you get access to those elements.
# to do that, we'll have to edit the session configuration again.
$pssc = @{
    Path = ".\jeamodule\jea.pssc"
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts\'
    LanguageMode = "FullLanguage"
    SessionType = "RestrictedRemoteServer"
    Full = $true
    RoleDefinitions = @{
        "home.lab\jea" = @{
            RoleCapabilities = "jea_basic"
        }
    }
}
New-PSSessionConfigurationFile @pssc

invoke-command $session {
    remove-item -path "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea.pssc"
}
Copy-Item -ToSession $session -path ".\jeamodule\jea.pssc" -Destination "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea.pssc" -Force
invoke-command $session {
    unregister-pssessionconfiguration -name "jea"
    register-pssessionconfiguration -name "jea" -Path "C:\Program Files\WindowsPowerShell\Modules\jeamodule\jea.pssc"
    restart-service -name winrm
}
# you DO have to restart WinRM when you add or edit a session configuration.

# let's try using some language again
$jeasession = New-PSSession -ComputerName "SERVER-1" -Credential $credential.bob -ConfigurationName "jea"
invoke-command $jeasession {
    if (1 + 1 -eq 2) {
        get-service
    }
}