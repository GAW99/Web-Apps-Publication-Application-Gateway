@maxLength(10)
@minLength(3)
@description('Prefix will be used in names of resources')
param service string 

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
    //sa.properties.primaryEndpoints.web
//    httpPort: 80
    httpsPort: 443
    originHostHeader: replace(replace(sa.properties.primaryEndpoints.web,'https://',''),'/','')
    priority: 1
    weight: 1000
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup('KeyVaultRG-NorthEU')
  name: 'KeyStorage01'
  resource secret 'secrets' existing = {
    name: '20220214-Common-Certificate-chain'
  }
}

resource secret 'Microsoft.Cdn/profiles/secrets@2021-06-01' = {
  name: '${service}-Certif'
  parent: FD
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: true
      secretVersion: ''
      secretSource: {
        id: KeyVault::secret.id
      }
    }
  }
}

resource CustomDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: 'CustomDoamin1'
  parent: FD
  properties: {
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
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
output result1 string = fd_id
output result2 string = 'Microsoft.Network/applicationGateways/${service}-FD'
