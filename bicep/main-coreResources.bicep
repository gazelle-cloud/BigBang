targetScope = 'subscription'

param workloadName string
param environment string
param logAnalyticsUseAzureRbac bool
param enableTelemetry bool
param federatedCredentials object
param location string

func repos(name string, githubOrganizationName string, githubRepoName string, environment string) object => {
  name: name
  audiences: [
    'api://AzureADTokenExchange'
  ]
  issuer: 'https://token.actions.githubusercontent.com'
  subject: 'repo:${githubOrganizationName}/${githubRepoName}:environment:${environment}'
}
var federatedCredentialsLoop = [
  for item in items(federatedCredentials): repos(item.key, item.value.org, item.value.repo, item.value.env)
]

resource bigBangRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${workloadName}-${environment}'
  location: location
}

module bigBangIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'bigBang-identity-${environment}'
  scope: bigBangRG
  params: {
    name: 'id-${workloadName}-${environment}'
    federatedIdentityCredentials: federatedCredentialsLoop
  }
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.3.4' = {
  name: 'logs-${environment}'
  scope: bigBangRG
  params: {
    name: 'la-${workloadName}-${environment}'
    useResourcePermissions: logAnalyticsUseAzureRbac
    enableTelemetry: enableTelemetry
  }
}

output managementIdentityResourceId string = bigBangIdentity.outputs.resourceId
output managementIdentityObjectId string = bigBangIdentity.outputs.principalId
output managementIdentityClientId string = bigBangIdentity.outputs.clientId
output logAnalyticsResourceId string = logAnalytics.outputs.resourceId
