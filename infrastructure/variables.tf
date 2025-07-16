# General Configuration
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "adsmicrosite"
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "The Azure region for the deployment"
  type        = string
  default     = "Central US"
}

# Resource Group
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = ""
}

# Static Web App Configuration
variable "sku_tier" {
  description = "The SKU tier for the Static Web App"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either 'Free' or 'Standard'."
  }
}

# Tags
variable "tags" {
  description = "Environment-specific tags to assign to resources (merged with computed common tags)"
  type        = map(string)
  default     = {}
}
