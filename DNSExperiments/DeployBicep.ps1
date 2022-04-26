Connect-AzAccount -Subscription d8274949-d913-4075-9b9c-d3a839fb5a30

New-AzResourceGroupDeployment -Name 'AllDeploy1' -ResourceGroupName "WebAppsGWRG-northeurope" -TemplateFile ".\DeployAll.bicep" -Mode Incremental #-whatif