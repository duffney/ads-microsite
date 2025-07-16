# Production Environment Configuration
project_name = "adsmicrosite"
environment  = "prod"
location     = "Central US"

# GitHub Repository Configuration
github_repository_url = "https://github.com/duffney/ads-microsite"
github_branch         = "main"

# Static Web App Configuration
sku_tier = "Free"

# Custom Domain (add your domain here when ready)
custom_domain_name = ""

# Environment-specific tags (merged with computed tags in locals)
tags = {
  Purpose    = "marketing-microsite"
  CostCenter = "marketing"
  Owner      = "platform-team"
}
