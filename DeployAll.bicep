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
param service string 

param WildnameCertificate object 

module AppGW '../26/WebApps.bicep' = {
  name: 'WebAppsGatewayDeployment'
  params: {
    location:location
    service: service
    WildnameCertificate:WildnameCertificate
  }
}
