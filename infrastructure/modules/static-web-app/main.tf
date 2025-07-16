# modules/static-web-app/main.tf

# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Static Web App with environment-specific app settings
resource "azurerm_static_web_app" "this" {
  name                = var.static_web_app_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  sku_tier = var.sku_tier
  sku_size = var.sku_tier

  app_settings = {
    "ENVIRONMENT"   = var.environment
    "PROJECT_NAME"  = var.project_name
    "FEATURE_FLAGS" = var.environment == "prod" ? "analytics:true,monitoring:true" : "analytics:false,monitoring:false"
    "API_BASE_URL"  = var.environment == "prod" ? "https://api.production.com" : "https://api.development.com"
  }

  tags = var.tags
}
