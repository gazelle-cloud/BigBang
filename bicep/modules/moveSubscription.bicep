targetScope = 'managementGroup'

param subcriptionId string
param managementGroupName string

resource moveSubscriptions 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  scope: tenant()
  name: '${managementGroupName}/${subcriptionId}'
}
