az group create --location germanywestcentral --name management
az group create --location germanywestcentral --name remotedev
az storage account create -n terraformstatebjh00 -g management -l germanywestcentral --sku Standard_LRS
