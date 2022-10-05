try
{

    $configFileLocation = $args[0] + "\\" + "Config.json";

    $config = Get-Content $configFileLocation | ConvertFrom-Json

    $subscriptionId = $config.LoginDetails.SubscriptionId
    $resourceGroupName = $config.ResourceGroupDetails.Name
    $resourceGroupRegion = $config.ResourceGroupDetails.Region 

    if(!$?)
    {
      Write-Host "Exiting"
      return
    }

    "Step 1 - Resource Group create"
    "Started"
    $existsResourceGroup = az group exists --name $resourceGroupName 

    if($existsResourceGroup -eq "true")
    {
      Write-OutPut "The resource group exists"
      return
    }

    az group create --location $resourceGroupRegion --name $resourceGroupName

    if(!$?)
    {
      Write-Host "Resource group is not created"
      return
    }

    Write-Host "Resource group is created Successfully"  
}
catch
{

}