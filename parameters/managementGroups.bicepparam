using '../bicep/main-managementGroups.bicep'

param enableTelemetry = false
param childManagementGroupNames = [
  'platform'
  'playground'
  'online'
]
