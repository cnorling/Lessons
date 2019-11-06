# generate a dsc configuration that looks just like a function
configuration basic {

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node 'SERVER-1' {
        WindowsFeature RSAT {
            ensure  = "present"
            name    = "RSAT-AD-TOOLS"
        }
    }
}
basic -outputpath .\

# take the file and copy it to the remote computer
copy-item -ToSession $session -Path ".\SERVER-1.mof" -Destination C:\mofs\

# call start-dscconfiguration to see what it does
Invoke-Command $session {
    Start-DscConfiguration -Wait -Verbose
}

# purposely break the configuration and see what dsc does
Invoke-Command $session {
    Get-WindowsFeature 'RSAT-AD-TOOLS' | Remove-WindowsFeature
    Start-DscConfiguration -wait -Verbose -UseExisting
}
