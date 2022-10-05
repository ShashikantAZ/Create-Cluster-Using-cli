try
{

    $configFileLocation = $args[0] + "\\" + "Config.json";
    $outputsFileLocation = $args[0] + "\" + "Outputs.json";
    $sshKey = $args[0] + "\SSH_Keys.pub"

    $config = Get-Content $configFileLocation | ConvertFrom-Json
    $outConfig = Get-Content $outputsFileLocation | Out-String | ConvertFrom-Json

    $subscriptionId = $config.LoginDetails.SubscriptionId
    $resourceGroupName = $config.ResourceGroupDetails.Name
    $resourceGroupRegion = $config.ResourceGroupDetails.Region 
    $clusterName = $config.ClusterName
    $vnetSubnetDefaultId =$outConfig.VnetSubnetDefaultId
    $azureActiveDirectoryGroupId = $outConfig.AzureActiveDirectoryGroupId
    $tenantId= az account show --query tenantId --output tsv
    $winUserName = $config.WindowsUsernamePassword.UserName
    $winPassword = $config.WindowsUsernamePassword.Password
    $logAnalyticsWorkspaceId = $outConfig.LogAnalyticsWorkspaceId

    "Started"
    "Step 1 - Create AKS Cluster"
    
    $existsResourceGroup = az group exists --name $resourceGroupName 

    if($existsResourceGroup -eq "false")
    {
      Write-OutPut "The resource group exists"
      return
    }

    az aks create --resource-group  $resourceGroupName `
              --name $clusterName `
              --enable-managed-identity `
              --ssh-key-value  $sshKey `
              --admin-username aksnodeadmin `
              --node-count 1 `
              --enable-cluster-autoscaler `
              --min-count 1 `
              --max-count 100 `
              --network-plugin azure `
              --service-cidr 10.0.0.0/16 `
              --dns-service-ip 10.0.0.10 `
              --docker-bridge-address 172.17.0.1/16 `
              --vnet-subnet-id $vnetSubnetDefaultId `
              --enable-aad `
              --aad-admin-group-object-ids $azureActiveDirectoryGroupId `
              --aad-tenant-id $tenantId `
              --windows-admin-password $winPassword `
              --windows-admin-username $winUserName `
              --node-osdisk-size 30 `
              --node-vm-size Standard_DS2_v2 `
              --nodepool-labels nodepool-type=system nodepoolos=linux app=system-apps `
              --nodepool-name systempool `
              --nodepool-tags nodepool-type=system nodepoolos=linux app=system-apps `
              --enable-addons monitoring `
              --workspace-resource-id $logAnalyticsWorkspaceId `
              --enable-ahub 

      
}
catch
{

}