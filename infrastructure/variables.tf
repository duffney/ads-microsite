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

# GitHub Repository Configuration (for reference)
variable "github_repository_url" {
  description = "GitHub repository URL for the static web app"
  type        = string
  default     = "https://github.com/duffney/ads-microsite"
}

variable "github_branch" {
  description = "GitHub branch for deployment"
  type        = string
  default     = "main"
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

# Custom Domain Configuration
variable "custom_domain_name" {
  description = "Custom domain name for the static web app"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Environment-specific tags to assign to resources (merged with computed common tags)"
  type        = map(string)
  default     = {}
}
