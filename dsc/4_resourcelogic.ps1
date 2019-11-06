
$cdata = @{
    allnodes = @(
        @{
            nodename = "SERVER-1"
            windowsfeature = "RSAT-AD-TOOLS"
        }
        @{
            nodename = "SERVER-2"
            windowsfeature = "RSAT-AD-TOOLS"
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
        WindowsFeature RSAT {
            ensure  = "present"
            name    = $node.windowsfeature
        }
    }
}
withlogic -outputpath .\ -configurationdata $cdata