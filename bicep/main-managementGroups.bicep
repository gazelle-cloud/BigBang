targetScope = 'managementGroup'

param childManagementGroupNames array
param managementSubscriptionId string = ''

// these values are fetch from Github variables
param topLevelManagementGroupName string = ''
param environment string = ''

module child 'modules/managementGroups.bicep' = [
  for item in childManagementGroupNames: {
    name: 'mgmtGroup-${item}-${environment}'
    params: {
      parentManagementGroupId: topLevelManagementGroupName
      managementGroupName: '${item}-${environment}'
    }
  }
]

module moveSubscription 'modules/moveSubscription.bicep' = {
  name: 'move-management-subscription-${environment}'
  dependsOn: [
    child
  ]
  params: {
    managementGroupName: 'platform-${environment}'
    subcriptionId: managementSubscriptionId
  }
}

module defaultSettings 'modules/managementGroupSettings.bicep' = if (environment == 'prod') {
  name: 'default-managementGroup-settings'
  dependsOn: [
    child
  ]
  params: {
    defaultManagementGroup: 'playground-${environment}'
  }
}
