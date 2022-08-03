targetScope = 'resourceGroup'

//Function App
var functionAppName = 'func-365response-${envPlusSuffix}-${formattedInstanceNum}'
var appInsName = 'appins-365response-${envPlusSuffix}-${formattedInstanceNum}'
module functionAppDeploy '365Response.functionApp.bicep' = {
  name: 'functionAppDeploy'
  params: {
    functionAppName: functionAppName
    appInsName: appInsName
    appPlanId: appSvcPlanDeploy.outputs.planId
    storageAccountName: storageAccountName
    env: env
    subscriptionId: subscriptionId
    rgLocation: rgLocation
    storageAccountId: storageAccountDeploy.outputs.storageAccountId
  }
  dependsOn: [
    storageAccountDeploy
  ]
}

//The following request for exisrting function app will fail on 1st run
//but works file if re-run. 
resource functionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: functionAppName
  scope: resourceGroup(subscriptionId, 'rg-365response-${env}-001')
}

resource funcSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${kvName}/funcAppKey'
  properties: {
    value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
  }
}
