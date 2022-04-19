@maxLength(10)
@minLength(3)
@description('Prefix will be used in names of resources')
param service string 

param WEBAppsIPs array

param PublicCertID string

param AzureDNSZoneID string

param AzureDNSZoneName string

var fd_id = resourceId('Microsoft.Network/applicationGateways', '${service}-FD')

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'testbicepstatic'
  scope: resourceGroup('05c55d9c-2fdd-49ca-9011-4dc4a28d50a5','TestingStaticWeb')
}

output endpointweb string = sa.properties.primaryEndpoints.web

resource FD 'Microsoft.Cdn/profiles@2021-06-01' = {
    name: '${service}-FD'
    location: 'global'
    sku:{
      name:'Standard_AzureFrontDoor'
    }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: '${service}-Endpoint'
  parent: FD
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource OOS_Endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: 'OOS-Endpoint'
  parent: FD
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource Autodiscover_Endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: 'Autodiscover-Endpoint'
  parent: FD
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: '${service}-OriginGroup'
  parent: FD
  properties: {    
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 10
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: '${service}-Origin'
  parent: originGroup
  properties: {
    hostName: replace(replace(sa.properties.primaryEndpoints.web,'https://',''),'/','')
//    httpPort: 80
    httpsPort: 443
    originHostHeader: replace(replace(sa.properties.primaryEndpoints.web,'https://',''),'/','')
    priority: 1
    weight: 1000
  }
}

resource OOS_Origin_Group 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: 'OOS-Origin-Group'
  parent: FD
  properties: {    
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/hosting/discovery'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 10
    }
  }
}

resource OOS1_Origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(WEBAppsIPs)): {
  name: 'OOS1-Origin-${i+1}'
  parent: OOS_Origin_Group
  properties: {
    hostName: WEBAppsIPs[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'oos-f1.gaw00.tk'
    priority: 1
    weight: 1000
  }
}]

resource Autodiscover_Origin_Group 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: 'Autodiscover-Origin-Group'
  parent: FD
  properties: {    
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/Autodiscover/healthcheck.htm'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 10
    }
  }
}

resource Autodiscover_Origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(WEBAppsIPs)): {
  name: 'Autodiscover-Origin-${i+1}'
  parent: Autodiscover_Origin_Group
  properties: {
    hostName: WEBAppsIPs[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'Autodiscover.gaw00.tk'
    priority: 1
    weight: 1000
  }
}]

resource secret 'Microsoft.Cdn/profiles/secrets@2021-06-01' = {
  name: '${service}-Certif'
  parent: FD
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: true
      secretVersion: ''
      secretSource: {
        id: PublicCertID
      }
    }
  }
}

resource CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'CustomDoamin1'
  parent: FD
  properties: {
    azureDnsZone: {
       id: AzureDNSZoneID
    }
    hostName: 'fd.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

module CustomDNSRecords 'FDDNSRecords.bicep' =  {
  name:'CustomDNSRecords'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostName: CustomDomain.properties.hostName   
    ValidationData: CustomDomain.properties.validationProperties.validationToken
    Target: endpoint.properties.hostName
    AzureDNSZoneID: AzureDNSZoneName
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'TestRoute'
  parent: endpoint
  dependsOn:[
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {    
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
     // 'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    customDomains:[
      {
        id:CustomDomain.id
      }
    ]
  }
}

resource OOS_CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'OOS-CustomDomain'
  parent: FD
  properties: {
    azureDnsZone: {
      id: AzureDNSZoneID
    }
    hostName: 'oos-f1.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

module OOSDNSRecords 'FDDNSRecords.bicep' =  {
  name:'OOSDNSRecords'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostName: OOS_CustomDomain.properties.hostName   
    ValidationData: OOS_CustomDomain.properties.validationProperties.validationToken
    Target: OOS_Endpoint.properties.hostName
    AzureDNSZoneID: AzureDNSZoneName
  }
}

resource OOS_Route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'OOS-Route'
  parent: OOS_Endpoint
  dependsOn:[
    OOS1_Origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {    
    originGroup: {
      id: OOS_Origin_Group.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    //httpsRedirect: 'Enabled'
    customDomains:[
      {
        id:OOS_CustomDomain.id
      }
    ]
  }
}

resource Autodiscover_CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'Autodiscover-CustomDomain'
  parent: FD
  properties: {
    azureDnsZone: {
      id: AzureDNSZoneID
    }
    hostName: 'Autodiscover.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

module AutodiscoverDNSRecords 'FDDNSRecords.bicep' =  {
  name:'AutodiscoverDNSRecords'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostName: Autodiscover_CustomDomain.properties.hostName   
    ValidationData: Autodiscover_CustomDomain.properties.validationProperties.validationToken
    Target: Autodiscover_Endpoint.properties.hostName
    AzureDNSZoneID: AzureDNSZoneName
  }
}

resource Autodiscover_Route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'Autodiscover-Route'
  parent: Autodiscover_Endpoint
  dependsOn:[
    Autodiscover_Origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {    
    originGroup: {
      id: Autodiscover_Origin_Group.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    //httpsRedirect: 'Enabled'
    customDomains:[
      {
        id:Autodiscover_CustomDomain.id
      }
    ]
  }
}

//mail.gaw00.tk Area
resource OWA_Endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: 'OWA-Endpoint'
  parent: FD
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource OWA_Origin_Group 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: 'OWA-Origin-Group'
  parent: FD
  properties: {    
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/OWA/healthcheck.htm'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 10
    }
  }
}

resource OWA_Origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(WEBAppsIPs)): {
  name: 'OWA-Origin-${i+1}'
  parent: OWA_Origin_Group
  properties: {
    hostName: WEBAppsIPs[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'mail.gaw00.tk'
    priority: 1
    weight: 1000
  }
}]

resource OWA_CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'OWA-CustomDomain'
  parent: FD
  properties: {
    azureDnsZone: {
      id: AzureDNSZoneID
    }
    hostName: 'mail.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

module OWADNSRecords 'FDDNSRecords.bicep' =  {
  name:'OWADNSRecords'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostName: OWA_CustomDomain.properties.hostName   
    ValidationData: OWA_CustomDomain.properties.validationProperties.validationToken
    Target: OWA_Endpoint.properties.hostName
    AzureDNSZoneID: AzureDNSZoneName
  }
}

resource OWA_Route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'OWA-Route'
  parent: OWA_Endpoint
  dependsOn:[
    OWA_Origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {    
    originGroup: {
      id: OWA_Origin_Group.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    customDomains:[
      {
        id:OWA_CustomDomain.id
      }
    ]
  }
}

//CA.gaw00.tk Area
resource CA_Endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: 'CA-Endpoint'
  parent: FD
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource CA_Origin_Group 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: 'CA-Origin-Group'
  parent: FD
  properties: {    
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 0
    }
    healthProbeSettings: {
      probePath: '/certsrv'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 10
    }
  }
}

resource CA_Origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(WEBAppsIPs)): {
  name: 'CA-Origin-${i+1}'
  parent: CA_Origin_Group
  properties: {
    hostName: WEBAppsIPs[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'ca.gaw00.tk'
    priority: 1
    weight: 1000
  }
}]

resource CA_CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'CA-CustomDomain'
  parent: FD
  properties: {
    azureDnsZone: {
      id: AzureDNSZoneID
    }
    hostName: 'ca.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

module CADNSRecords 'FDDNSRecords.bicep' =  {
  name:'CADNSRecords'
  scope: resourceGroup('DNSRG-NorthEU')
  params: {
    HostName: CA_CustomDomain.properties.hostName   
    ValidationData: CA_CustomDomain.properties.validationProperties.validationToken
    Target: CA_Endpoint.properties.hostName
    AzureDNSZoneID: AzureDNSZoneName
  }
}

resource CA_Route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'CA-Route'
  parent: CA_Endpoint
  dependsOn:[
    CA_Origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {    
    originGroup: {
      id: CA_Origin_Group.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    //httpsRedirect: 'Enabled'
    customDomains:[
      {
        id:CA_CustomDomain.id
      }
    ]
  }
}

output frontDoorEndpointHostNames array = [
  endpoint.properties.hostName
  OOS_Endpoint.properties.hostName
]
output result1 string = fd_id
output CustomDomainNames array = [
  substring(OOS_CustomDomain.properties.hostName,0,indexOf(OOS_CustomDomain.properties.hostName,'.'))
  substring(CustomDomain.properties.hostName,0,indexOf(CustomDomain.properties.hostName,'.'))
]

output CustomDomainValidation array = [
  OOS_CustomDomain.properties.validationProperties.validationToken
  CustomDomain.properties.validationProperties.validationToken
]

output OOSCustomDoamin string = OOS_CustomDomain.properties.hostName
