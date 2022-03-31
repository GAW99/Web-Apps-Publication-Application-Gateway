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
  }
}

//output IP string = AppGW.outputs.IP
//output IPAddressHostName string = AppGW.outputs.IPAddressHostName

