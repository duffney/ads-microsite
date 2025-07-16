# modules/static-web-app/outputs.tf

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "static_web_app_id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_web_app.this.id
}

output "static_web_app_name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_web_app.this.name
}

output "default_host_name" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_web_app.this.default_host_name
}

output "api_key" {
  description = "The API key of the Static Web App"
  value       = azurerm_static_web_app.this.api_key
  sensitive   = true
}
