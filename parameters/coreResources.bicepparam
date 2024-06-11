using '../bicep/main-coreResources.bicep'

param workloadName = 'bigBang'
param logAnalyticsUseAzureRbac = true
param enableTelemetry = false
param federatedCredentials = {
  managementGroups: {
    org: 'gazelle-cloud'
    repo: 'policies'
    env: environment
  }
  landingzones: {
    org: 'gazelle-cloud'
    repo: 'landingzones'
    env: environment
  }
}


// these values are fetched from the GitHub variables
param environment = ''
param location = ''
