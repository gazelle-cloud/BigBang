
function reset-managementGroup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$managementGroupName,

        [Parameter(Mandatory = $false)]
        [bool]$deleteDeployments = $false
    )
    $tenantId = (Get-AzContext).Tenant.Id
    Write-Output "tenantId: $tenantId"


    Get-AzManagementGroupSubscription -GroupName 'platform-test' | foreach-object {
        $SubscriptionId = $_.Id.Split('/')[-1]
        Write-Output "selecting context: $SubscriptionId"
        Select-AzSubscription -Subscription $SubscriptionId
        Write-Output "getting deployment stacks"
        $deploymentStacks = Get-AzSubscriptionDeploymentStack
        Write-Output "stacks found: $($deploymentStacks.Count)"
        foreach ($stack in $deploymentStacks) {
            if ($deleteDeployments) {
                Write-Output "removing deployment stack for subscription $($stack.name)"
                Remove-AzSubscriptionDeploymentStack -name $stack.name -ActionOnUnmanage  'DeleteAll' -Force
            }
        }
        Write-Output "moving subscription $SubscriptionId to $($tenantId)"
        New-AzManagementGroupSubscription -SubscriptionId $SubscriptionId -GroupName $tenantId
    }
}
