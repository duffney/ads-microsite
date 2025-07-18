# Configure the Azure Provider and Backend
terraform {
  required_version = "1.9.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "adsmicrosite-tfstate-prod"
    storage_account_name = "adsmicrositetfprod1651"
    container_name       = "tfstate"
    key                  = "ads-microsite.terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "de9002e6-0573-43f4-8cbc-7f644a2631fd"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
