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

# Application Insights for monitoring and observability
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-${var.environment}-ai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = 30
  tags                = var.tags
}

# Basic heartbeat monitor (availability test)
resource "azurerm_application_insights_standard_web_test" "main" {
  name                    = "${var.project_name}-heartbeat"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  application_insights_id = azurerm_application_insights.main.id
  description             = "Basic heartbeat monitor for ${var.project_name} microsite"
  frequency               = 300 # 5 minutes
  timeout                 = 30
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "emea-nl-ams-azr"] # North America and Europe coverage
  tags                    = var.tags

  request {
    url                              = "https://${azurerm_static_web_app.main.default_host_name}"
    http_verb                        = "GET"
    parse_dependent_requests_enabled = false
  }

  validation_rules {
    expected_status_code = 200
    ssl_check_enabled    = true
  }
}

# Custom domain for Static Web App (if specified)
resource "azurerm_static_web_app_custom_domain" "main" {
  count             = var.custom_domain_name != "" ? 1 : 0
  static_web_app_id = azurerm_static_web_app.main.id
  domain_name       = var.custom_domain_name
  validation_type   = "dns-txt-token"
}
