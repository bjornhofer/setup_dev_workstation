terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">=3.50.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "management"
        storage_account_name = "terraformstatebjh00"
        container_name       = "terraform"
        key                  = "remotedev.tfstate"
    }
}
provider "azurerm" {
    subscription_id = local.settings.subscription_id
    features {}
}