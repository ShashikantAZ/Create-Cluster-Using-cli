try
{

    $configFileLocation = $args[0] + "\" + "Config.json";

    $configFileLocation = $configFileLocation.replace('\','\\')

    Write-OutPut $configFileLocation

    $config = Get-Content $configFileLocation | ConvertFrom-Json

    $subscriptionId = $config.LoginDetails.SubscriptionId
    $resourceGroupName = $config.ResourceGroupDetails.Name
    $vnet = $config.VirtualNetworkDetails.Vnet
    $vnetAddressPrefix = $config.VirtualNetworkDetails.VnetAddressPrefix
    $subnetDefault = $config.VirtualNetworkDetails.SubnetDefault
    $subnetDefaultPrefix = $config.VirtualNetworkDetails.SubnetDefaultPrefix
    $subnetVirtualNodes = $config.VirtualNetworkDetails.SubnetVirtualNodes
    $subnetVirtualNodesPrefix = $config.VirtualNetworkDetails.SubnetVirtualNodesPrefix

    "Step 1 - # Create Virtual Network & default Subnet"
    "Started"
    $existsResourceGroup = az group exists --name $resourceGroupName

    if($existsResourceGroup -eq "false")
    {
      Write-OutPut "The resource group is not exists"
      return
    }

    az network vnet create -g $resourceGroupName  -n $vnet --address-prefix $vnetAddressPrefix --subnet-name $subnetDefault --subnet-prefix $subnetDefaultPrefix 
    if(!$?)
    {
      Write-Host "Vnet is not created"
      return
    }
    
    Write-Host "Vnet is created"

    # Create Virtual Nodes Subnet in Virtual Network
    az network vnet subnet create --resource-group $resourceGroupName --vnet-name $vnet --name $subnetVirtualNodes --address-prefixes $subnetVirtualNodesPrefix

    if(!$?)
    {
      Write-Host "Subnet is not created"
      return
    }

     Write-Host "Subnet is created"

    # Get Virtual Network default subnet id
    $VnetSubnetDefaultId=$(az network vnet subnet show --resource-group $resourceGroupName --vnet-name $vnet --name $subnetDefault --query id -o tsv)

    # Add Virtual Network default subnet id into json
    $jsonRepresentation='{"VnetSubnetDefaultId":"'+$VnetSubnetDefaultId+'"}'

    $Path = $args[0] + "\Outputs.json"
    if (!(Test-Path $Path))
    {
      New-Item -itemType File -Path $args[0] -Name ("Outputs.json")
    }

    Write-OutPut $getConfigFileLocation
    $jsonRepresentation | Out-File $Path

    Write-Host "Completed"  
}
catch
{

}