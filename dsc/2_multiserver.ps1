# generate a dsc configuration for three servers to do the same thing
configuration multiserver {

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node 'SERVER-1' {
        WindowsFeature RSAT {
            ensure  = "present"
            name    = "RSAT-AD-TOOLS"
        }
    }

    node 'SERVER-2' {
        WindowsFeature RSAT {
            ensure  = "present"
            name    = "RSAT-AD-TOOLS"
        }
    }

    node 'SERVER-3' {
        WindowsFeature RSAT {
            ensure  = "present"
            name    = "RSAT-AD-TOOLS"
        }
    }
}
multiserver -outputpath .\