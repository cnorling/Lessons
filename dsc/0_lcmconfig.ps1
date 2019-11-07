# create lcm configuration
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node 'SERVER-1' {
        Settings {
            RefreshMode = 'Push'
            ConfigurationMode = 'applyandautocorrect'
        }
    }
}
lcmconfig -outputpath .\

# create pssession with target node
$session = New-PSSession -VMName 'SERVER-1' -Credential $credential.domainadmin

# get current lcm configuration
Invoke-Command $session {
    Get-DscLocalConfigurationManager
}
# copy configuration over to target node
copy-item -ToSession $session -Path ".\SERVER-1.meta.mof" -Destination C:\mofs\

# call update lcm configuration on target node
Invoke-Command $session {
    Set-DscLocalConfigurationManager -Path 'C:\mofs'
}

# get new lcm configuration
Invoke-Command $session {
    Get-DscLocalConfigurationManager
}