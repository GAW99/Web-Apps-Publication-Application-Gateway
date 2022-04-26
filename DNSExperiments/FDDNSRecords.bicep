param AzureDNSZoneID string
param HostNames array
param Targets array
param ValidationData array

/*
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: AzureDNSZoneName
  location: 'global'
}
*/

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for i in range(0, length(HostNames)) :{
  name: '${AzureDNSZoneID}/${HostNames[i]}'
  //parent: dnsZone
  properties: {
    TTL: 3600

    CNAMERecord: {
      cname: Targets[i]
    }
  }
}]

resource CNAME 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: '${AzureDNSZoneID}/pass'
  //parent:dnsZone
  properties:{
    TTL: 3600
    targetResource:{
      id:'/subscriptions/d8274949-d913-4075-9b9c-d3a839fb5a30/resourceGroups/WebAppsGWRG-northeurope/providers/Microsoft.Network/publicIPAddresses/WebAppsGW_PublicIP'
    }
  }
}

resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = [for i in range(0, length(HostNames)) :{
  //parent: dnsZone
  name: '${AzureDNSZoneID}/_dnsauth.${HostNames[i]}'
  properties: {
    TTL: 1000
    TXTRecords: [
      {
        value: [
          ValidationData[i]
        ]
      }
    ]
  }
}]

output Length int = length(HostNames)
