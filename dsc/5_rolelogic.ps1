
$cdata = @{
    allnodes = @(
        @{
            nodename = "SERVER-1"
            roles = @(
                "domaincontroller"
                "dns"
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

    # domain controller role
    node $allnodes.where({$_.roles -contains "domaincontroller"}).nodename {

    }

    # dns role
    node $allnodes.where({$_.roles -contains "dns"}).nodename {

    }

    # dhcp role
    node $allnodes.where({$_.roles -contains "dhcp"}).nodename {

    }

    # pki role
    node $allnodes.where({$_.roles -contains "pki"}).nodename {

    }

    # webserver role
    node $allnodes.where({$_.roles -contains "webserver"}).nodename {

    }
}
withrolelogic -outputpath .\ -configurationdata $cdata