# poss-demo-vmss

### Autoscale a VM Scale Set running a .NET Core app ###

Simple self-contained .NET Core autoscale & load balancing example. VM Scale Set scales up when avg CPU across all VMs > 60%, scales down when avg CPU < 30%.

- Deploy the VM Scale Set with an instance count of 1 
- After it is deployed look at the resource group public IP address resource (in portal or resources explorer). Get the IP or domain name.
- Browse to the website (port 80), which shows the current backend VM name.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpascals-msft%2Fposs-demo-vmss%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

