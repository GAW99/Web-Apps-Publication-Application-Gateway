Connect-AzAccount -Subscription d8274949-d913-4075-9b9c-d3a839fb5a30
#1 - Visual Studio Enterprise — MPN d8274949-d913-4075-9b9c-d3a839fb5a30 4d18e547-6b51-4c00-bf8a-a94237a983fb Enabled
#2 - Visual Studio Enterprise — MPN 9829c6c3-e2f8-4746-9a8f-0ca77dec04e1 4d18e547-6b51-4c00-bf8a-a94237a983fb Enabled
#3 - Visual Studio Enterprise — MPN 05c55d9c-2fdd-49ca-9011-4dc4a28d50a5 4d18e547-6b51-4c00-bf8a-a94237a983fb Enabled
#4 - Visual Studio Enterprise — MPN 6ae3f1ca-2b7d-43c2-a7a4-dc9e84390a34 4d18e547-6b51-4c00-bf8a-a94237a983fb Enabled
#Set-AzContext -Subscription 05c55d9c-2fdd-49ca-9011-4dc4a28d50a5 # 3
#New-AzSubscriptionDeployment -Name AppGateway -TemplateFile ".\WebAppRG v1.bicep" -Location "northeurope" -service "WebAppsGW" -WhatIf

New-AzResourceGroupDeployment -Name AppGateway1 -ResourceGroupName "WebAppsGWRG-northeurope" -TemplateFile ".\WebApps.bicep" `
-Mode Incremental -Service "WebAppsGW" -TemplateParameterFile ".\WebApps.parameters.json" #-whatif

(New-AzResourceGroupDeployment -Name AllDeploy -ResourceGroupName "WebAppsGWRG-northeurope" -TemplateFile ".\DeployAll.bicep" `
-Mode Incremental -WebAppGWService "WebAppsGW" -TemplateParameterFile ".\DeployAll.parameters.json" -FDService "FrontDoor" ).ProvisioningState

#$result.ProvisioningState

#Register App
New-AzADServicePrincipal -ApplicationId "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8"

New-AzResourceGroupDeployment -Name FrontDoordeployment -ResourceGroupName "FDRG-northeurope" -TemplateFile ".\FrontDoor.bicep" `
-Mode Incremental -Service "FrontDoor" #-whatif