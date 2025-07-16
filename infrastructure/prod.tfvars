# Production Environment Configuration
project_name = "adsmicrosite"
environment  = "prod"
location     = "Central US"

# GitHub Repository Configuration
github_repository_url = "https://github.com/duffney/ads-microsite"
github_branch         = "main"

# Resource Group (empty to use default naming)
resource_group_name = ""

# Static Web App Configuration
sku_tier = "Free"

# Custom Domain (add your domain here when ready)
custom_domain_name = ""

# Tags
tags = {
  Project     = "ads-microsite"
  Environment = "production"
  ManagedBy   = "terraform"
  Purpose     = "marketing-microsite"
  CostCenter  = "marketing"
  Owner       = "platform-team"
}
