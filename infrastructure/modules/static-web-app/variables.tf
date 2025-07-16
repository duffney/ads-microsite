# modules/static-web-app/variables.tf

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
  description = "Name of the static web app"
  type        = string
}

variable "sku_tier" {
  description = "The pricing tier for the Static Web App"
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
