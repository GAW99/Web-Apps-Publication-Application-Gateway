//param AzureDNSZoneID string
param AzureDNSZoneName string
param HostNames array
param Targets array
//param CurrentValidationData array

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: AzureDNSZoneName
  location: 'global'
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for i in range(0, length(HostNames)-1) :{
  name: HostNames[i]
  parent: dnsZone
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: Targets[i]
    }
  }
}]
