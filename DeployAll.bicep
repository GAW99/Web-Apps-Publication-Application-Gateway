@allowed([
  'northeurope'
  'westeurope'
  'ukwest'
  'uksouth'
])
param location string = 'northeurope'

@maxLength(10)
@minLength(3)
@description('Prefix will be used in names of resources')
param WebAppGWService string 

@maxLength(10)
@minLength(3)
@description('Prefix will be used in names of resources')
param FDService string 

param WildnameCertificate object 

resource KeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup('KeyVaultRG-NorthEU')
  name: 'KeyStorage01'
  resource secret 'secrets' existing = {
    name: '20220214-Common-Certificate-chain'
  }
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: 'gaw00.tk'
  scope: resourceGroup('dnsrg-northeu')
}

var PublicCertID = KeyVault::secret.id

module AppGW '../26/WebApps.bicep' = {
  name: 'WebAppsGatewayDeployment'
  scope: resourceGroup('WebAppsGWRG-northeurope')
  params: {
    location:location
    service: WebAppGWService
    WildnameCertificate:WildnameCertificate
  }
}

var FDBackendIPs =  [
  AppGW.outputs.IP
  AppGW.outputs.IP
  ] 

module FD '../26/FrontDoor.bicep' = {
  name: 'FrontDoorDeployment'
  scope: resourceGroup('FDRG-northeurope')
  params: {
//    location:location
    service: FDService
    WEBAppsIPs:FDBackendIPs
    PublicCertID:PublicCertID
    AzureDNSZoneID:dnsZone.id
  }
}

var FDDomainNames = FD.outputs.CustomDomainNames
var FDDoaminValidation = FD.outputs.CustomDomainValidation
var FDEndpoints = FD.outputs.frontDoorEndpointHostNames


module CNAMERecord '../26/FDDNSRecords.bicep' =  {
  name:'RecordCreation'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostNames:FDDomainNames   
    //CurrentValidationData: '${FDDoaminValidation[i]}.gaw00.tk'
    Targets: FDEndpoints
    //AzureDNSZoneID: 
    AzureDNSZoneName: 'gaw00.tk'
  }
}

/*
//scope: resourceGroup('DNSRG-NorthEU')
= [for i in range(0, length(WEBAppsIPs)-1): {
  name: 'OOS1-Origin-${i+1}'
  parent: OOS_Origin_Group
  properties: {
    hostName: WEBAppsIPs[i]

// Create a valid resource name for the custom domain. Resource names don't include periods.
var customDomainResourceName = replace('${cnameRecordName}.${dnsZoneName}', '.', '-')
var dnsRecordTimeToLive = 3600

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
}

var FDDomainNames = FD.outputs.CustomDomainNames

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for i in range(0, length(FDDomainNames)-1): {
  parent: dnsZone
  name: FDDomainNames[i]
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: FD.outputs.frontDoorEndpointHostName
    }
  }
}


resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: dnsZone
  name: '_dnsauth.${cnameRecordName}'
  properties: {
    TTL: dnsRecordTimeToLive
    TXTRecords: [
      {
        value: [
          customDomain.properties.validationProperties.validationToken
        ]
      }
    ]
  }
}
*/
//output IP string = AppGW.outputs.IP
//output IPAddressHostName string = AppGW.outputs.IPAddressHostName

output HostNames array = FD.outputs.CustomDomainNames
output HostNamesValidation array = FD.outputs.CustomDomainValidation
output TargetEndpoints array = FD.outputs.frontDoorEndpointHostNames
//output DNSData string = dnsZone.id

