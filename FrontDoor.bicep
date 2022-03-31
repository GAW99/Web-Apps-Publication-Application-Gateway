@maxLength(10)
@minLength(3)
@description('Prefix will be used in names of resources')
param service string 

//param WEBAppsIP1 string
param WEBAppsIPs array

param PublicCertID string

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

resource OOS1_Origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(WEBAppsIPs)-1): {
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
/*
resource KeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup('KeyVaultRG-NorthEU')
  name: 'KeyStorage01'
  resource secret 'secrets' existing = {
    name: '20220214-Common-Certificate-chain'
  }
}*/

resource secret 'Microsoft.Cdn/profiles/secrets@2021-06-01' = {
  name: '${service}-Certif'
  parent: FD
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: true
      secretVersion: ''
      secretSource: {
        //id: KeyVault::secret.id
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
       id: '/subscriptions/d8274949-d913-4075-9b9c-d3a839fb5a30/resourceGroups/dnsrg-northeu/providers/Microsoft.Network/dnszones/gaw00.tk'
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

resource OOS_CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'OOS-CustomDomain'
  parent: FD
  properties: {
    azureDnsZone: {
       id: '/subscriptions/d8274949-d913-4075-9b9c-d3a839fb5a30/resourceGroups/dnsrg-northeu/providers/Microsoft.Network/dnszones/gaw00.tk'
    }
    hostName: 'oos-t.gaw00.tk'
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
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

output frontDoorEndpointHostName string = endpoint.properties.hostName
output result1 string = fd_id
