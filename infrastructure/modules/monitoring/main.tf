# modules/monitoring/main.tf

# Application Insights for monitoring and analytics
resource "azurerm_application_insights" "this" {
  name                = var.resource_names.application_insights
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  retention_in_days = var.monitoring_config.retention_days

  tags = var.tags
}

# Web test for availability monitoring
resource "azurerm_application_insights_web_test" "global_monitor" {
  name                    = var.resource_names.web_test
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.this.id
  kind                    = "ping"
  frequency               = var.monitoring_config.frequency
  timeout                 = var.monitoring_config.timeout
  enabled                 = true
  geo_locations           = var.monitoring_config.geo_locations

  configuration = <<XML
<WebTest Name="${var.resource_names.web_test}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="${var.monitoring_config.timeout}" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Version="1.1" Url="${var.static_web_app_url}" ThinkTime="0" Timeout="${var.monitoring_config.timeout}" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

  tags = var.tags
}

# Action Group for alert notifications
resource "azurerm_monitor_action_group" "alerts" {
  name                = var.resource_names.action_group
  resource_group_name = var.resource_group_name
  short_name          = "alerts"

  # Add email notifications - these would be configured via variables in real use
  # email_receiver {
  #   name          = "admin"
  #   email_address = var.admin_email
  # }

  tags = var.tags
}

# Availability Alert
resource "azurerm_monitor_metric_alert" "availability" {
  name                = var.resource_names.availability_alert
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights_web_test.global_monitor.id]
  description         = "Alert when ${var.project_name} availability drops below ${var.monitoring_config.availability_threshold}%"

  criteria {
    metric_namespace = "microsoft.insights/webtests"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.monitoring_config.availability_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = var.environment == "prod" ? 1 : 2

  tags = var.tags
}

# Response Time Alert
resource "azurerm_monitor_metric_alert" "response_time" {
  name                = var.resource_names.response_time_alert
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights_web_test.global_monitor.id]
  description         = "Alert when ${var.project_name} response time exceeds ${var.monitoring_config.response_time_threshold}ms"

  criteria {
    metric_namespace = "microsoft.insights/webtests"
    metric_name      = "availabilityResults/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.monitoring_config.response_time_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = var.environment == "prod" ? 2 : 3

  tags = var.tags
}
