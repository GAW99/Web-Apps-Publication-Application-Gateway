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

var appgw_id = resourceId('Microsoft.Network/applicationGateways', '${service}_AppGW')

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'testbicepstatic'
  scope: resourceGroup('05c55d9c-2fdd-49ca-9011-4dc4a28d50a5','TestingStaticWeb')
}

output endpoint string = sa.properties.primaryEndpoints.web

resource virtualnetname 'Microsoft.Network/virtualNetworks@2021-05-01' existing  = {
  name: 'HUBVNet'  
  scope: resourceGroup('d8274949-d913-4075-9b9c-d3a839fb5a30','NetworkRG-NorthEU')
    resource Subnet 'subnets@2021-05-01' existing ={
      name: 'WebAppGatewaySubnet'
    }    
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${service}_PublicIP'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'    
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: '${service}_AppGW'
  location: location
  properties: {    
    sku: {
      name: 'Standard_Small'
      tier: 'Standard'
      capacity: 1      
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {          
          subnet: {
            //id: resourceId('virtualnetname::Microsoft.Network/virtualNetworks/subnets', virtualnetname.id, 'WebAppGatewaySubnet')
            id: '/subscriptions/d8274949-d913-4075-9b9c-d3a839fb5a30/resourceGroups/NetworkRG-NorthEU/providers/Microsoft.Network/virtualNetworks/HUBVNet/subnets/WebAppGatewaySubnet'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: '${service}_PublicFrontendIp'
        properties: {          
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPAddress.name)
          }         
        }
      }      
    ]
    frontendPorts: [
      {
        name: 'HTTP80'
        properties: {
          port: 80
        }
      }      
      {
        name: 'HTTPS443'
        properties:{
          port: 443          
        }
      }      
    ]
    backendAddressPools: [
      {
        name: 'OOS_Pool'
        properties:{          
          backendAddresses: [
            {
              fqdn: 'OOS-1.gaw00.local'
            }
          ]                    
        }
      }    
      {
        name: 'CA_Pool'
        properties:{          
          backendAddresses: [
            {
              fqdn: 'DC-1.gaw00.local'
            }
          ]                    
        }
      }    
      {
        name: 'Exch_Pool'
        properties:{          
          backendAddresses: [
            {
              fqdn: 'EXCH-1.gaw00.local'
            }
            {
              fqdn: 'EXCH-2.gaw00.local'
            }
          ] 
        }
      }  
      {
        name: 'ADFS_Pool'
        properties:{          
          backendAddresses: [
            {
              fqdn: 'ADFS-1.gaw00.local'
            }
            {
              fqdn: 'ADFS-2.gaw00.local'
            }
          ] 
        }
      }
      {
        name: 'UCFE_Pool'
        properties:{          
          backendAddresses: [
            {
              fqdn: 'UCFE-1.gaw00.local'
            }
            {
              fqdn: 'UCFE-2.gaw00.local'
            }
          ] 
        }
      }    
    ]
    probes:[
      {
        name:'OOS_HTTP_Probe_1'        
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/hosting/discovery'
          protocol: 'Http'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'OOS_HTTPS_Probe_1'        
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/hosting/discovery'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      } 
      {
        name:'OAB_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/oab/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }   
      {
        name:'EWS_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/ews/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      } 
      {
        name:'RPC_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/rpc/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }   
      {
        name:'MAPI_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/mapi/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }  
      {
        name:'ActiveSync_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/Microsoft-Server-ActiveSync/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }  
      {
        name:'ECP_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/ecp/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'OWA_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/owa/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'Autodiscover_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/Autodiscover/healthcheck.htm'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'CA_HTTPS_Probe_1'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/certsrv'
          protocol: 'Https'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'CA_HTTP_Probe_1'        
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/hosting/discovery'
          protocol: 'Http'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }      
    ]    
    backendHttpSettingsCollection: [
      {
        name: 'OOS_HTTP_Settings_1'        
        properties: {          
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20  
          probe:{
            id: '${appgw_id}/probes/OOS_HTTP_Probe_1'
          }                
        }
      }         
      {
        name: 'OOS_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/OOS_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/OOS_Cert_1'                          
            }
          ]
        }
      }  
      {
        name: 'CA_HTTP_Settings_1'      
        properties: {          
          port: 80          
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20  
          probe:{
            id: '${appgw_id}/probes/CA_HTTP_Probe_1'
          }                
        }
      }  
      {
        name: 'CA_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/CA_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }        
      {
        name: 'OAB_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/OAB_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'EWS_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/EWS_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'RPC_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/RPC_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'MAPI_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/MAPI_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'ActiveSync_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/ActiveSync_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'ECP_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/ECP_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'OWA_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/OWA_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }
      {
        name: 'Autodiscover_HTTPS_Settings_1'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/Autodiscover_HTTPS_Probe_1'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }      
    ]

    authenticationCertificates:[
      {
        name: 'OOS_Cert_1'
        properties:{
          data:'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'
        }
      }
      {
        name: 'CA_Int_Cert_1'
        properties:{
          data:'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'
        }
      }      
      {
        name: 'SSL_Cert_Ext_WildName'
        properties:{
          data: 'MIIFGjCCBAKgAwIBAgISA341bfvZO4crGotsFmc3NPRTMA0GCSqGSIb3DQEBCwUAMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQDEwJSMzAeFw0yMjAyMTQwOTA3MzRaFw0yMjA1MTUwOTA3MzNaMBUxEzARBgNVBAMMCiouZ2F3MDAudGswggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCODm20FY7AZmDJ9ywoTpbV0QKDlsF3rtaGMDuDlhtx5NWky/gxULqARvosJQ3Apc2FtHFxT0VzIkM2qlAR9/bZuY/FzeZ0Tf44kvXyupvfSMCUDbY2hvoEA5vsC5aMqpYnEEOQkG576EozEojZrARbGuhfrpgyGRAJwfmfIBdd+XJMvZ0PzNeD5jB3IsJ7ebOP5hXQv84U6cNC8c/seYf2v7d+aQhflt+ocBevyMT+WMNFL8tWnwgrh0mNvw86YW7O+9eHUT8bvO50SlxAlfxaGcg3M6NsRQZAJyxyccgEUtiPXPtNlZuRTzI+VprA7/iRt0+WxKktlxdzixQvDdsJAgMBAAGjggJFMIICQTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFKJHZ64qCQJYP0/INOphCjtPtCjDMB8GA1UdIwQYMBaAFBQusxe3WFbLrlAJQOYfr52LFMLGMFUGCCsGAQUFBwEBBEkwRzAhBggrBgEFBQcwAYYVaHR0cDovL3IzLm8ubGVuY3Iub3JnMCIGCCsGAQUFBzAChhZodHRwOi8vcjMuaS5sZW5jci5vcmcvMBUGA1UdEQQOMAyCCiouZ2F3MDAudGswTAYDVR0gBEUwQzAIBgZngQwBAgEwNwYLKwYBBAGC3xMBAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5jcnlwdC5vcmcwggEEBgorBgEEAdZ5AgQCBIH1BIHyAPAAdgDfpV6raIJPH2yt7rhfTj5a6s2iEqRqXo47EsAgRFwqcwAAAX73s64pAAAEAwBHMEUCIQDgPk5ATzmq/cpOERCzQi80zEIVmxIqakJXvUgGVGMl5wIgNM7dr5jGvfimvFlUl9PuHzUxZFKRcXxQnTep1uT1MswAdgBGpVXrdfqRIDC1oolp9PN9ESxBdL79SbiFq/L8cP5tRwAAAX73s65RAAAEAwBHMEUCIQCIOdmnYlttLw5L99UIMP5ueO4Kb9CaoXwQ2R6/qFo/agIgEX36DizdKBbjhGA8ENW+tAQ66t7ly94tY4EsFzO6iG8wDQYJKoZIhvcNAQELBQADggEBAErDhvkrq5HyWuTsgbW9R1CcTr23+wCI96mw23iWzVwLM+aiB6uFMIH93upA31i8sGiFwsdqwXjXtZyEogwJMktA5hbmO9UXgSMuo+RGwoy8xmP+skySqguD4GIZJdWENM3xPCwjI2O7uE3tXoMrCLbSU3a/0RG6dhLiMBDiZJZhMkcKIVZjc0I/CibQSwELCD6kGrAALA2iPAOxbABym1ehd6X4gV/9Vc75JrogEw4lZIodvOQ5JDWOPctuXCuuR+azNdseDGAowSv94zhaYz78+KdUsiYzTSGjG3lNPf7G4pzZdgT4YrnSLAuPiRcARs2o85o5sy+GfkiRsiTYKDk='
        }
      }
    ]         
    sslCertificates:[
       {
         name: 'SSL_Cert_Ext_WildName'
         properties:{
           data: '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'
           password: '1'
          }
       }
    ]     
    httpListeners: [
      {
        name: 'OOS_HTTP_80_Listener'
        properties: {
          hostName: 'OOS-F1.gaw00.tk'            
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${service}_AppGW', '${service}_PublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${service}_AppGW', 'HTTP80')
          }
          protocol: 'Http'
          requireServerNameIndication: false          
        }
      }
      {
        name: 'OOS_HTTPS_443_Listener'
        properties: {
          hostName: 'OOS-F1.gaw00.tk'            
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${service}_AppGW', '${service}_PublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${service}_AppGW', 'HTTPS443')
          }
          protocol: 'Https'
          requireServerNameIndication: false  
          sslCertificate:{
            id: '${appgw_id}/sslCertificates/SSL_Cert_Ext_WildName'
          }        
        }
      }       
      {
        name: 'CA_HTTPS_443_Listener'
        properties: {
          hostName: 'CA.gaw00.tk'            
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${service}_AppGW', '${service}_PublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${service}_AppGW', 'HTTPS443')
          }
          protocol: 'Https'
          requireServerNameIndication: false  
          sslCertificate:{
            id: '${appgw_id}/sslCertificates/SSL_Cert_Ext_WildName'
          }        
        }
      } 
      {
        name: 'CA_HTTP_80_Listener'        
        properties: {          
          hostName: 'CA.gaw00.tk'            
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${service}_AppGW', '${service}_PublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${service}_AppGW', 'HTTP80')
          }
          protocol: 'Http'
          requireServerNameIndication: false          
        }
      } 
    ]    
    requestRoutingRules: [
      {
        name: 'OOS_HTTP_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'OOS_HTTP_80_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'OOS_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'OOS_HTTP_Settings_1')
          }
        }
      }
      {
        name: 'OOS_HTTPS_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'OOS_HTTPS_443_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'OOS_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'OOS_HTTPS_Settings_1')
          }
        }
      }
      {
        name: 'CA_HTTPS_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'CA_HTTPS_443_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'CA_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'CA_HTTPS_Settings_1')
          }
        }
      }
      {
        name: 'CA_HTTP_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          redirectConfiguration:{
            id:'${appgw_id}/redirectConfigurations/HTTP_to_HTTPS'
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'CA_HTTP_80_Listener')
          }         
        }
      }      
    ]
    redirectConfigurations:[
      {
        name: 'HTTP_to_HTTPS'
        properties:{
          redirectType: 'Permanent'
          targetListener:{
            id: '${appgw_id}/httpListeners/CA_HTTPS_443_Listener'            
          }
          includePath:true
          includeQueryString:true
        }
      }
    ]
    enableHttp2: false    
  }

  dependsOn: [
    virtualnetname
    //publicIPAddress
  ]
}
