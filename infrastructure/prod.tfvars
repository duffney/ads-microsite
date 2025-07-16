# Production Environment Configuration
project_name = "adsmicrosite"
environment  = "prod"
location     = "Central US"

# Static Web App Configuration
sku_tier = "Free"

# Environment-specific tags (merged with computed tags in locals)
tags = {
  Purpose    = "marketing-microsite"
  CostCenter = "marketing"
  Owner      = "platform-team"
}
