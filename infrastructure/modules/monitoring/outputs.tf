# modules/monitoring/outputs.tf

output "application_insights_id" {
  description = "The ID of the Application Insights resource"
  value       = azurerm_application_insights.this.id
}

output "application_insights_name" {
  description = "The name of the Application Insights resource"
  value       = azurerm_application_insights.this.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "web_test_id" {
  description = "The ID of the availability web test"
  value       = azurerm_application_insights_web_test.global_monitor.id
}

output "action_group_id" {
  description = "The ID of the action group for alerts"
  value       = azurerm_monitor_action_group.alerts.id
}
