param AzureDNSZoneID string
param ValidationData string
param HostName string
param Target string

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${AzureDNSZoneID}/${substring(HostName,0,indexOf(HostName,'.'))}'
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: Target
    }
  }
}

resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: '${AzureDNSZoneID}/_dnsauth.${substring(HostName,0,indexOf(HostName,'.'))}'
  properties: {
    TTL: 1000
    TXTRecords: [
      {
        value: [
          ValidationData
        ]
      }
    ]
  }
}
