try
{

    $configFileLocation = $args[0] + "\\" + "Config.json";
    $outputsFileLocation = $args[0] + "\" + "Outputs.json";

    $config = Get-Content $configFileLocation | ConvertFrom-Json

    $outConfig = Get-Content $outputsFileLocation | Out-String | ConvertFrom-Json

    $subscriptionId = $config.LoginDetails.SubscriptionId
    $resourceGroupName = $config.ResourceGroupDetails.Name
    $azureActiveDirectoryGroupName = $config.AzureActiveDirectoryDetails.AzureActiveDirectoryGroupName
    $userId = $config.AzureActiveDirectoryDetails.Users.UserId
    $password = $config.AzureActiveDirectoryDetails.Users.Password
   
    "Started"
    "Step 1 - Create Azure AD Group"
    
    $existsResourceGroup = az group exists --name $resourceGroupName

    if($existsResourceGroup -eq "false")
    {
      Write-OutPut "The resource group is not exists"
      return
    }
  az group create -l westus -n testAD --query "id"
  $aDGroupId= az ad group create --display-name $azureActiveDirectoryGroupName --mail-nickname $azureActiveDirectoryGroupName --query "id" -o tsv  

   "Step 2 - Create Azure AD  User"
  # Create Azure AD AKS Admin User 
  $aDUserId= az ad user create --display-name $userId --user-principal-name $userId --password $password --query "id" -o tsv

  "Step 3 - Associate AKS Admin User to AKS Admins Group"
  # Associate aksadmin User to aksadmins Group
  az ad group member add --group $azureActiveDirectoryGroupName --member-id $aDUserId
 
  "Step 4 - Create SSH Key"
  # Create SSH Key

  $keyPath=$args[0] +"\SSH_Keys"

  ssh-keygen -m PEM -t rsa -b 4096  -f $keyPath -N mypassphrase

  "Step 5 - Create Log Analytics Workspace"

  $logAnalyticsWorkspaceId=az monitor log-analytics workspace create --resource-group $resourceGroupName --workspace-name aksprod-loganalytics-workspace1 --query id -o tsv

  "Step 6 - Preparing Outputs file"

  if (-not $outConfig.'AzureActiveDirectoryGroupId') {
  $outConfig | Add-Member -Type NoteProperty -Name 'AzureActiveDirectoryGroupId' -Value $aDGroupId
  }
  else
  {
    $outConfig.PSObject.Properties.Remove('AzureActiveDirectoryGroupId')
    $outConfig | Add-Member -Type NoteProperty -Name 'AzureActiveDirectoryGroupId' -Value $aDGroupId
  }
  if (-not $outConfig.'AdminUserId') {
    $outConfig | Add-Member -Type NoteProperty -Name 'AdminUserId' -Value $aDUserId
  }
  else
  {
    $outConfig.PSObject.Properties.Remove('AdminUserId')
    $outConfig | Add-Member -Type NoteProperty -Name 'AdminUserId' -Value $aDUserId
  }
  if (-not $outConfig.'LogAnalyticsWorkspaceId') {
    $outConfig | Add-Member -Type NoteProperty -Name 'LogAnalyticsWorkspaceId' -Value $logAnalyticsWorkspaceId
  }
  else
  {
    $outConfig.PSObject.Properties.Remove('LogAnalyticsWorkspaceId')
    $outConfig | Add-Member -Type NoteProperty -Name 'LogAnalyticsWorkspaceId' -Value $logAnalyticsWorkspaceId
  }
  $outConfig | ConvertTo-Json | Set-Content $outputsFileLocation

  "Completed"

}
catch
{

}