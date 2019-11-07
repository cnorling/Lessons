
$cdata = @{
    allnodes = @(
        @{
            nodename = "SERVER-1"
            roles = @(
                "dhcp"
            )
        }
        @{
            nodename = "SERVER-2"
            roles = @(
                "pki"
            )
        }
        @{
            nodename = "SERVER-3"
            roles = @(
                "webserver"
            )
        }
    )
}

configuration withrolelogic {
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    # dhcp role
    node $allnodes.where({$_.roles -contains "dhcp"}).nodename {
        windowsfeature dhcp 
        {
            ensure      = 'present'
            name        = 'dhcp'
        }
    }

    # pki role
    node $allnodes.where({$_.roles -contains "pki"}).nodename {
        windowsfeature pki 
        {
            ensure      = 'Present'
            name        = 'pki'
        }
    }

    # webserver role
    node $allnodes.where({$_.roles -contains "webserver"}).nodename {
        windowsfeature iis 
        {
            ensure      = 'present'
            name        = 'web-server'
        }

        environment website 
        {
            Ensure      = 'Present'
            Name        = 'ASPNETCORE_ENVIRONMENT'
            Value       = 'Production'
        }
    }
}
withrolelogic -outputpath .\ -configurationdata $cdata