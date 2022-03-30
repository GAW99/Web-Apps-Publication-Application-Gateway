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

var appgw_id = resourceId('Microsoft.Network/applicationGateways', '${service}_AppGW')

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
            //id: resourceId('Microsoft.Network/publicIPAddresses', publicIPAddress.name)
            id: publicIPAddress.id
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
        name: 'EXCH_Pool'
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
        name:'OOS_HTTP_Probe'        
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
        name:'OOS_HTTPS_Probe'        
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
        name:'OAB_HTTPS_Probe'     
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
        name:'EWS_HTTPS_Probe'     
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
        name:'RPC_HTTPS_Probe'     
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
        name:'MAPI_HTTPS_Probe'     
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
        name:'ActiveSync_HTTPS_Probe'     
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
        name:'ECP_HTTPS_Probe'     
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
        name:'OWA_HTTPS_Probe'     
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
        name:'Autodiscover_HTTPS_Probe'     
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
        name:'Autodiscover_HTTP_Probe'     
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/Autodiscover/healthcheck.htm'
          protocol: 'Http'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }
      {
        name:'CA_HTTPS_Probe'     
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
        name:'CA_HTTP_Probe'        
        properties:{
          pickHostNameFromBackendHttpSettings: true
          path: '/certsrv'
          protocol: 'Http'   
          timeout: 30
          interval:30
          unhealthyThreshold: 5          
        }
      }      
    ]    
    backendHttpSettingsCollection: [
      {
        name: 'OOS_HTTP_Settings'        
        properties: {          
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20  
          probe:{
            id: '${appgw_id}/probes/OOS_HTTP_Probe'
          }                
        }
      }         
      {
        name: 'OOS_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/OOS_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/OOS_Cert'                          
            }
          ]
        }
      }  
      {
        name: 'CA_HTTP_Settings'      
        properties: {          
          port: 80          
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20  
          probe:{
            id: '${appgw_id}/probes/CA_HTTP_Probe'
          }                
        }
      }  
      {
        name: 'CA_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/CA_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/SSL_Cert_Ext_WildName'                          
            }
          ]
        }
      }        
      {
        name: 'OAB_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true
          probe:{
            id: '${appgw_id}/probes/OAB_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'EWS_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/EWS_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'RPC_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/RPC_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'MAPI_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true           
          probe:{
            id: '${appgw_id}/probes/MAPI_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'ActiveSync_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: true
          probe:{
            id: '${appgw_id}/probes/ActiveSync_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'ECP_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: false
          hostName: 'mail.gaw00.tk'         
          probe:{
            id: '${appgw_id}/probes/ECP_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'OWA_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: false   
          hostName: 'mail.gaw00.tk'        
          probe:{
            id: '${appgw_id}/probes/OWA_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }
      {
        name: 'Autodiscover_HTTPS_Settings'
        properties:{
          protocol: 'Https'
          port: 443
          pickHostNameFromBackendAddress: false  
          hostName: 'Autodiscover.gaw00.tk'            
          probe:{
            id: '${appgw_id}/probes/Autodiscover_HTTPS_Probe'
          }
          authenticationCertificates: [
            {
              id: '${appgw_id}/authenticationCertificates/EXCH_IIS_Int_Cert'                          
            }
          ]
        }
      }   
      {
        name: 'Autodiscover_HTTP_Settings'
        properties:{
          protocol: 'Http'
          port: 80
          pickHostNameFromBackendAddress: false  
          hostName: 'Autodiscover.gaw00.tk'            
          probe:{
            id: '${appgw_id}/probes/Autodiscover_HTTP_Probe'
          }         
        }
      }     
    ]
    authenticationCertificates:[
      {
        name: 'OOS_Cert'
        properties:{
          data:'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'
        }
      }
      {
        name: 'CA_Int_Cert'
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
      {
        name: 'EXCH_IIS_Int_Cert'
        properties:{
          data: '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'
        }
      }
    ]         
    sslCertificates:[
       {
         name: 'SSL_Cert_Ext_WildName'
         properties:{
            data:WildnameCertificate.Data
           password:WildnameCertificate.Password
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
      {
        name: 'EXCH_HTTP_80_Listener'
        properties: {
          hostName: 'mail.gaw00.tk'                      
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
        name: 'EXCH_HTTPS_443_Listener'
        properties: {
          hostName: 'mail.gaw00.tk'            
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
        name: 'Autodiscover_HTTP_80_Listener'
        properties: {
          hostName: 'Autodiscover.gaw00.tk'                      
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
        name: 'Autodiscover_HTTPS_443_Listener'
        properties: {
          hostName: 'Autodiscover.gaw00.tk'            
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
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'OOS_HTTP_Settings')
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
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'OOS_HTTPS_Settings')
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
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'CA_HTTP_Settings')
          }
        }
      }
      {
        name: 'CA_HTTP_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          redirectConfiguration:{
            id:'${appgw_id}/redirectConfigurations/CA_HTTP_to_HTTPS'
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'CA_HTTP_80_Listener')
          }         
        }
      }     
      {
        name: 'EXCH_HTTPS_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'EXCH_HTTPS_443_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'EXCH_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'OWA_HTTPS_Settings')
          }
        }
      }
      {
        name: 'EXCH_HTTP_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          redirectConfiguration:{
            id:'${appgw_id}/redirectConfigurations/EXCH_HTTP_to_HTTPS'
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'EXCH_HTTP_80_Listener')
          }         
        }
      } 
      {
        name: 'Autodiscover_HTTPS_RoutingRule'
        properties: {          
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'Autodiscover_HTTPS_443_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'EXCH_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'Autodiscover_HTTPS_Settings')
          }
        }
      }
      {
        name: 'Autodiscover_HTTP_RoutingRule'
        properties: {          
          ruleType: 'Basic'          
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${service}_AppGW', 'Autodiscover_HTTP_80_Listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${service}_AppGW', 'EXCH_Pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${service}_AppGW', 'Autodiscover_HTTP_Settings')
          }         
        }
      }    
    ]
    redirectConfigurations:[
      {
        name: 'CA_HTTP_to_HTTPS'
        properties:{
          redirectType: 'Permanent'
          targetListener:{
            id: '${appgw_id}/httpListeners/EXCH_HTTPS_443_Listener'            
          }
          includePath:true
          includeQueryString:true
        }
      }
      {
        name: 'EXCH_HTTP_to_HTTPS'
        properties:{
          redirectType: 'Permanent'
          targetListener:{
            id: '${appgw_id}/httpListeners/EXCH_HTTPS_443_Listener'            
          }
          includePath:true
          includeQueryString:true
        }
      }
     /* {
        name: 'Autodiscover_HTTP_to_HTTPS'
        properties:{
          redirectType: 'Permanent'
          targetListener:{
            id: '${appgw_id}/httpListeners/Autodiscover_HTTPS_443_Listener'            
          }
          includePath:true
          includeQueryString:true
        }
      }*/
    ]
    enableHttp2: false    
  }

  dependsOn: [
    virtualnetname
    //publicIPAddress
  ]
}

output IP string = publicIPAddress.properties.ipAddress
output IPAddressHostName string = publicIPAddress.properties.dnsSettings.fqdn
