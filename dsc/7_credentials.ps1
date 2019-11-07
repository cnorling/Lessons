# If you use DSC for any length of time, you'll need to use credentials in some of your DSC resources. 
# it's inevitable if you want to interact with domain based resources.
# there are some considerations to make when working with credentials

# show what happens when you run a configuration without encrypting the credentials

$plaintextusername = "home.lab\plaintext"
$plaintextpassword = ConvertTo-SecureString -AsPlainText -Force -String "pleasedontdothis"
$plaintextcredential =  new-object pscredential -argumentlist $plaintextusername,$plaintextpassword
$cdata = @{
    allnodes = @(
        @{
            nodename = '*'
        }
        @{
            nodename = "SERVER-1"
        }
    )
}

configuration plaintext {
    Import-DscResource -ModuleName "psdesiredstateconfiguration"

    node $allnodes.nodename {
        file supersecure
        {
            ensure          = "present"
            type            = "file"
            checksum        = "SHA-256"       
            MatchSource     = $true
            DestinationPath = "C:\filename.txt"
            sourcepath      = "\\server\share\filename.txt"
            credential      = $plaintextcredential
        }        
    }

}
plaintext -outputpath .\ -configurationdata $cdata

# you can't even create a dsc configuration without acknowledging that the credentials are in plaintext unless you encrypt them.
$cdata = @{
    allnodes = @(
        @{
            nodename = '*'
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = 'SERVER-1'
        }
    )
}
plaintext -outputpath .\ -configurationdata $cdata
code .\SERVER-1.mof

# let's go through the process of setting up encryption for your configurations
# generate a document encryption cert
$cert = invoke-command $session {
    New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256
}
$cert | Export-Certificate -FilePath ".\DscPublicKey.cer" -Force

# tell the LCM to use that cert for decryption
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node 'SERVER-1' {
        Settings {
            RefreshMode = 'Push'
            ConfigurationMode = 'applyandautocorrect'
            CertificateId = $cert.thumbprint
        }
    }
}
lcmconfig -outputpath .\
copy-item -ToSession $session -Path ".\SERVER-1.meta.mof" -Destination C:\mofs\
Invoke-Command $session {
    Set-DscLocalConfigurationManager -Path 'C:\mofs'
}

# add the thumbprint to your configurationdata
$cdata = @{
    allnodes = @(
        @{
            nodename = '*'
        }
        @{
            NodeName = 'SERVER-1'
            thumbprint = $cert.thumbprint
            certificatefile = ".\dscpublickey.cer"
        }
    )
}

# call the same configuration we had earlier without the plaintext password flag
plaintext -outputpath .\ -configurationdata $cdata
code .\SERVER-1.mof