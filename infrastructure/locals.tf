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
    Repository   = "ads-microsite"
    Owner        = "duffney"
  })
}
