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

# Local computed values for environment-specific configurations
locals {
  # Naming conventions
  naming_prefix = "${var.project_name}-${var.environment}"

  # Environment-specific monitoring configurations
  monitoring_config = {
    dev = {
      frequency               = 900 # 15 minutes for dev (cost optimization)
      timeout                 = 30
      availability_threshold  = 90   # Lower SLA for dev
      response_time_threshold = 3000 # 3 seconds for dev
      retention_days          = 30
      geo_locations           = ["us-ca-sjc-azr"] # Single region for dev
    }
    prod = {
      frequency               = 300 # 5 minutes for prod
      timeout                 = 30
      availability_threshold  = 95   # Higher SLA for prod
      response_time_threshold = 1500 # 1.5 seconds for prod
      retention_days          = 90
      geo_locations           = ["us-ca-sjc-azr", "emea-nl-ams-azr"] # Multi-region for prod
    }
  }

  # Current environment monitoring settings
  current_monitoring = local.monitoring_config[var.environment]

  # Resource naming
  resource_names = {
    resource_group       = var.resource_group_name != "" ? var.resource_group_name : "${local.naming_prefix}-rg"
    static_web_app       = "${local.naming_prefix}-swa"
    application_insights = "${local.naming_prefix}-ai"
    web_test             = "${var.project_name}-global-monitor"
    availability_alert   = "${var.project_name}-availability-alert"
    response_time_alert  = "${var.project_name}-response-time-alert"
    action_group         = "${var.project_name}-alerts"
  }

  # Enhanced tags with computed values
  common_tags = merge(var.tags, {
    Environment  = var.environment
    Project      = var.project_name
    ManagedBy    = "terraform"
    CreatedDate  = formatdate("YYYY-MM-DD", timestamp())
    NamingPrefix = local.naming_prefix
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_names.resource_group
  location = var.location
  tags     = local.common_tags
}

# Static Web App - Infrastructure only
resource "azurerm_static_web_app" "main" {
  name                = local.resource_names.static_web_app
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_tier
  tags                = local.common_tags

  # Note: GitHub integration handled via existing GitHub Actions workflow
  # This prevents Azure from auto-generating workflow files
}

# Application Insights for monitoring and observability
resource "azurerm_application_insights" "main" {
  name                = local.resource_names.application_insights
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = local.current_monitoring.retention_days
  tags                = local.common_tags
}

# Multi-region availability and performance test (environment-specific)
resource "azurerm_application_insights_standard_web_test" "main" {
  name                    = local.resource_names.web_test
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  application_insights_id = azurerm_application_insights.main.id
  description             = "Global availability and performance monitor for ${var.project_name} microsite"
  frequency               = local.current_monitoring.frequency
  timeout                 = local.current_monitoring.timeout
  enabled                 = true
  geo_locations           = local.current_monitoring.geo_locations
  tags                    = local.common_tags

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
  name                = local.resource_names.availability_alert
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when availability drops below acceptable thresholds"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = local.current_monitoring.availability_threshold
  }

  frequency   = "PT5M"  # Check every 5 minutes
  window_size = "PT15M" # 15-minute window
  severity    = 1       # Error level

  tags = local.common_tags
}

# Alert rule for response time monitoring (using Application Insights metrics)
resource "azurerm_monitor_metric_alert" "response_time" {
  name                = local.resource_names.response_time_alert
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response times exceed acceptable thresholds for global users"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = local.current_monitoring.response_time_threshold
  }

  frequency   = "PT5M"  # Check every 5 minutes
  window_size = "PT15M" # 15-minute window
  severity    = 2       # Warning level

  tags = local.common_tags
}

# Action group for alerts (can be extended with email/webhook notifications)
resource "azurerm_monitor_action_group" "main" {
  name                = local.resource_names.action_group
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "swa-alerts"

  tags = local.common_tags
}
