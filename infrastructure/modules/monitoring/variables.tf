# modules/monitoring/variables.tf

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "static_web_app_name" {
  description = "Name of the static web app to monitor"
  type        = string
}

variable "static_web_app_url" {
  description = "URL of the static web app to monitor"
  type        = string
}

variable "monitoring_config" {
  description = "Environment-specific monitoring configuration"
  type = object({
    frequency               = number
    timeout                 = number
    availability_threshold  = number
    response_time_threshold = number
    retention_days          = number
    geo_locations           = list(string)
  })
}

variable "resource_names" {
  description = "Resource naming configuration"
  type = object({
    application_insights = string
    web_test             = string
    availability_alert   = string
    response_time_alert  = string
    action_group         = string
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
