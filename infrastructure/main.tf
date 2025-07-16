# Configure the Azure Provider and Backend
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0" # Update to the latest stable version
    }
  }
  required_version = "1.9.6"

  backend "azurerm" {
    resource_group_name  = "adsmicrosite-tfstate-prod"
    storage_account_name = "adsmicrositetfprod1651"
    container_name       = "tfstate"
    key                  = "ads-microsite.terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Static Web App - Infrastructure only
resource "azurerm_static_web_app" "main" {
  name                = "${var.project_name}-${var.environment}-swa"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_tier
  tags                = var.tags

  # Note: GitHub integration handled via existing GitHub Actions workflow
  # This prevents Azure from auto-generating workflow files
}

# Custom domain for Static Web App (if specified)
resource "azurerm_static_web_app_custom_domain" "main" {
  count             = var.custom_domain_name != "" ? 1 : 0
  static_web_app_id = azurerm_static_web_app.main.id
  domain_name       = var.custom_domain_name
  validation_type   = "dns-txt-token"
}
