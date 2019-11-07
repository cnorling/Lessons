# generate a set of configuration data that we'll use as a library for what computers we have in our configuration


$cdata = @{
    allnodes = @(
        @{
            nodename = "SERVER-1"
        }
        @{
            nodename = "SERVER-2"
        }
        @{
            nodename = "SERVER-3"
        }
    )
}

configuration withcdata {
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node $allnodes.nodename {
        WindowsFeature RSAT 
        {
            ensure  = "present"
            name    = "RSAT-AD-TOOLS"
        }
    }
}
withcdata -outputpath .\ -configurationdata $cdata