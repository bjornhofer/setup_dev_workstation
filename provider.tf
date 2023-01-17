terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">=3.30.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "mangement"
        storage_account_name = "terraformstatebjh01"
        container_name       = "remotedev"
        key                  = "terraform.tfstate"
    }
}
provider "azurerm" {
    subscription_id = local.settings.subscription_id
    features {}
}