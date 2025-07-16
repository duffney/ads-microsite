# Development Environment Configuration
project_name = "adsmicrosite"
environment  = "dev"
location     = "Central US"

# Static Web App Configuration
sku_tier = "Free"

# Environment-specific tags (merged with computed tags in locals)
tags = {
  Purpose    = "marketing-microsite-dev"
  CostCenter = "marketing"
  Owner      = "platform-team"
}
