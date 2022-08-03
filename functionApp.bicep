param functionAppName string
param appInsName string
param appPlanId string
param storageAccountName string
param env string
param subscriptionId string
param rgLocation string = resourceGroup().location
param storageAccountId string

var vnetResourceGroup = 'rg-net-${env}-001'
var vnetName = 'vnet-${env}-uksouth'
var vnetPath = 'subscriptions/${subscriptionId}/resourceGroups/${vnetResourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnetName}'
var subnetPath = '${vnetPath}/subnets/${appSubnet}'
var storageHost = 'blob.${environment().suffixes.storage}'
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: rgLocation
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    httpsOnly: true
    serverFarmId: appPlanId
    virtualNetworkSubnetId: subnetPath
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountId, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountId, '2019-06-01').keys[0].value}'
        }
        {
          name: 'AZURE_STORAGE_HOST'
          value: storageHost
        }
        {
          name: 'AZURE_STORAGE_CONTAINER'
          value: 'response-invoices'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }
}
