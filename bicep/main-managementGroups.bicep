targetScope = 'managementGroup'

param enableTelemetry bool
param childManagementGroupNames array

// these values are fetch from Github variables
param topLevelManagementGroupName string = ''
param environment string = ''
param managementSubscriptionId string = ''

module topLevel 'br/public:avm/res/management/management-group:0.1.1' = {
  name: 'mgmtGroup-${topLevelManagementGroupName}-${environment}'
  params: {
    name: '${topLevelManagementGroupName}-${environment}'
    enableTelemetry: enableTelemetry
  }
}

module child 'modules/managementGroups.bicep' = [
  for item in childManagementGroupNames: {
    name: 'mgmtGroup-${item}-${environment}'
    params: {
      parentManagementGroupId: topLevel.outputs.resourceId
      managementGroupName: '${item}-${environment}'
    }
  }
]

// module moveSubscription 'modules/moveSubscription.bicep' = {
//   name: 'move-management-subscription-${environment}'
//   dependsOn: [
//     child
//   ]
//   params: {
//     managementGroupName: 'platform-${environment}'
//     subcriptionId: managementSubscriptionId
//   }
// }

module defaultSettings 'modules/managementGroupSettings.bicep' =
  if (environment == 'prod') {
    name: 'default-managementGroup-settings'
    dependsOn: [
      child
    ]
    params: {
      defaultManagementGroup: 'playground-${environment}'
    }
  }
