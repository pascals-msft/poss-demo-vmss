# poss-demo-vmss

### Azure VM Scale Set running a .NET Core app ###

This sample shows how to automate the deployment of a .NET Core application on an Azure Virtual Machine Scale Set with load balancing. Autoscale can be added to the template if needed. The `setup.sh` script does all the setup work on the VM instances during their provisionning.

How to use :

- Be sure to have Azure Xplat-CLI on your system: https://github.com/Azure/azure-xplat-cli.
- Get the parameters file: azuredeploy.parameters.json.
- Edit the parameters file. For example:
```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "ubuntuOSVersion": { 
      "value": "16.04.0-LTS"
    },
    "vmssName": {
      "value": "demo-vmss"
    },
    "instanceCount": {
      "value": 2
    },
    "adminUsername": {
      "value": "ubuntu"
    },
    "adminPassword": {
      "value": "My.V3ry.S3cur3.P4ssw0rd"
    }
  }
}
```
- Initiate the deployment with the `azure group create` command. For example, to deploy the sample in a new resource group named `RG_demo-vmss` in the West Europe region:
```
azure group create --name RG_demo-vmss --location westeurope --template-uri https://raw.githubusercontent.com/pascals-msft/poss-demo-vmss/master/azuredeploy.json --parameters-file azuredeploy.parameters.json

```
- Watch the deployment on the Azure portal (https://portal.azure.com) by watching the new resource group.
- Once the deployment is done, get the public IP address or DNS name and open it in a browser.

You can also click on this button and use the portal to enter the parameters and deploy the demo:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpascals-msft%2Fposs-demo-vmss%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

You can add or remove instances in the VM Scale Set with the `azure vmss scale` command. For example:
```
azure vmss scale --resource-group RG_demo-vmss --name demo-vmss --new-capacity 4

```
To remove the whole demo from your Azure subscription and save money, simply remove the resource group:
```
azure group delete RG_demo-vmss

```

The sample application can be found here: https://github.com/jcorioland/CloudArchi-Samples/tree/parisoss
