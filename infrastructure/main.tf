# Static Web App + Resource Group Module
module "static_web_app" {
  source = "./modules/static-web-app"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = local.resource_names.resource_group
  static_web_app_name = local.resource_names.static_web_app
  sku_tier            = var.sku_tier
  tags                = local.common_tags
}

# Monitoring Module (Application Insights + Alerts)
module "monitoring" {
  source = "./modules/monitoring"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.static_web_app.resource_group_name
  static_web_app_name = module.static_web_app.static_web_app_name
  static_web_app_url  = "https://${module.static_web_app.default_host_name}"
  monitoring_config   = local.current_monitoring
  resource_names      = local.resource_names
  tags                = local.common_tags
}
