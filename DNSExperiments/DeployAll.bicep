
var FDDomainNames = [
  'name1'
  'name2'
]
var FDEndpoints = [
  'gaw.zapto.org'
  'gaw.zapto.org'
]
var FDValidation = [
  'rubbish1'
  'rubbish2'
]

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: 'gaw00.tk'
  location: 'global'
}

module Record 'FDDNSRecords.bicep' = {
  name:'Record'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostNames:FDDomainNames   
    ValidationData: FDValidation
    Targets: FDEndpoints
    AzureDNSZoneID: dnsZone.name
  }
}

output Number int = Record.outputs.Length
