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

# Multi-region availability and performance test (US + EU)
resource "azurerm_application_insights_standard_web_test" "main" {
  name                    = "${var.project_name}-global-monitor"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  application_insights_id = azurerm_application_insights.main.id
  description             = "Global availability and performance monitor for ${var.project_name} microsite"
  frequency               = 300 # 5 minutes
  timeout                 = 30
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "emea-nl-ams-azr"] # US West and EU for global coverage per context.md
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

# Alert rule for availability monitoring (using Application Insights metrics)
resource "azurerm_monitor_metric_alert" "availability" {
  name                = "${var.project_name}-availability-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when availability drops below acceptable thresholds"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 95 # 95% availability threshold
  }

  frequency   = "PT5M"  # Check every 5 minutes
  window_size = "PT15M" # 15-minute window
  severity    = 1       # Error level

  tags = var.tags
}

# Alert rule for response time monitoring (using Application Insights metrics)
resource "azurerm_monitor_metric_alert" "response_time" {
  name                = "${var.project_name}-response-time-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response times exceed acceptable thresholds for global users"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1500 # 1.5 seconds threshold for consistently fast responses
  }

  frequency   = "PT5M"  # Check every 5 minutes
  window_size = "PT15M" # 15-minute window
  severity    = 2       # Warning level

  tags = var.tags
}

# Action group for alerts (can be extended with email/webhook notifications)
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.project_name}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "swa-alerts"

  tags = var.tags
}
