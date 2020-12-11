param(
    # The subscription id where the template will be deployed.
    [string]$subscriptionId = "0459dbd5-b73e-4a5b-b052-250dc51ac622",
    # The resource group in to which to deploy all the resources
    [string]$resourceGroupName = "SG-RG-AMADEUS-AZURE-MANAGEMENT",
    # Optional, Azure region to which to deploy all resources. Defaults to Central US.
    [string]$region = "westeurope",
    # Optional, name for the deployment. If not specified, deployment name will be "azuredeploy-yyyyMMdd-hhmmss" (for example, azuredeploy-20190724-083224).  Deployment to set up Azure Data Explorer will have "-dexdataconnection" appended to the base name.
    [string]$deploymentName = "Amadeus-NWNSG"
)

#region init
Set-PSDebug -Strict

Clear-Host
$d = get-date
Write-Host "Starting Deployment $d"

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "scriptFolder" $scriptFolder

set-location $scriptFolder
#endregion init

#Login-AzAccount -SubscriptionId $subscriptionId
#Select-AzSubscription -Subscription $subscriptionId >$null

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    if (!$region) {
        Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location."
        $region = Read-Host "region"
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$region'"
    New-AzResourceGroup -Name $resourceGroupName -Location $region >$null
}
else {
    Write-Host "Using existing resource group '$resourceGroupName'"
}

# Start the deployment
Write-Host "Deploying Azure resources..."


Test-AzResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "template.json" `
	-TemplateParameterFile "parameters.json" `
    -Debug -Verbose


New-AzResourceGroupDeployment `
    -Name $deploymentName `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "template.json" `
	-TemplateParameterFile "parameters.json" `
    -Debug -Verbose -DeploymentDebugLogLevel All

$d = get-date
Write-Host "Stopping Deployment $d"