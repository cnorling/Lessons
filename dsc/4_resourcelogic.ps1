
$cdata = @{
    allnodes = @(
        @{
            nodename = '*'
            windowsfeature = "RSAT-AD-TOOLS"
        }
        @{
            nodename = "SERVER-1"
        }
        @{
            nodename = "SERVER-2"
        }
        @{
            nodename = "SERVER-3"
            windowsfeature = "DHCP"
        }
    )
}

configuration withlogic {
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node $allnodes.nodename {
        WindowsFeature RSAT 
        {
            ensure  = "present"
            name    = $node.windowsfeature
        }
    }
}
withlogic -outputpath .\ -configurationdata $cdata