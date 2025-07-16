# Static Web App Outputs from module
output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${module.static_web_app.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for GitHub Actions deployment"
  value       = module.static_web_app.api_key
  sensitive   = true
}

output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = module.static_web_app.static_web_app_name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.static_web_app.resource_group_name
}

# Monitoring Outputs from module
output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "application_insights_name" {
  description = "Name of the Application Insights resource"
  value       = module.monitoring.application_insights_name
}

output "web_test_id" {
  description = "ID of the availability web test"
  value       = module.monitoring.web_test_id
}

output "monitoring_dashboard_url" {
  description = "URL to view Application Insights monitoring dashboard"
  value       = "https://portal.azure.com/#@/resource${module.monitoring.application_insights_id}/overview"
}
