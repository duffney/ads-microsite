# Static Web App - Essential Outputs
output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for GitHub Actions deployment"
  value       = azurerm_static_web_app.main.api_key
  sensitive   = true
}

output "github_repository_url" {
  description = "GitHub repository URL for deployment configuration"
  value       = var.github_repository_url
}

output "github_branch" {
  description = "GitHub branch for deployment"
  value       = var.github_branch
}

# Monitoring Outputs
output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "global_performance_test_id" {
  description = "Global performance test ID for US/EU monitoring"
  value       = azurerm_application_insights_standard_web_test.main.id
}

output "response_time_alert_id" {
  description = "Response time alert rule ID"
  value       = azurerm_monitor_metric_alert.response_time.id
}

output "monitoring_dashboard_url" {
  description = "URL to view Application Insights monitoring dashboard"
  value       = "https://portal.azure.com/#@/resource${azurerm_application_insights.main.id}/overview"
}
