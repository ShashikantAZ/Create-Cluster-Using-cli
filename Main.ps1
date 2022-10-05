try
{

    cls
     $configFileLocation = $PSScriptRoot + "\\" + "Config.json";
     $config = Get-Content $configFileLocation | ConvertFrom-Json
     $subscriptionId = $config.LoginDetails.SubscriptionId
     $resourceGroupName = $config.ResourceGroupDetails.Name
     $clusterName = $config.ClusterName

    #login To azure portal
    az login

    # using !$? check if last command execute successfully 
    if(!$?)
    {
      Write-Host "Exiting"
      return
    }

    az account set --subscription $subscriptionId

    "Start Setup To Azure Kubernetes Cluster"

    .\01CreateResourceGroup.ps1 $PSScriptRoot
    .\02CreateAzureVirtualNetworkAndTwoSubnets.ps1 $PSScriptRoot
    .\03CreateAzureADGroupAndAdminUser.ps1 $PSScriptRoot
    .\04CreateAKSCluster.ps1 $PSScriptRoot

    "Deploying Apps"
    az aks get-credentials --name $clusterName  --resource-group $resourceGroupName
    kubectl apply -f Apps\

    "Completed"
}
catch
{

}