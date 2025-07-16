# Development Environment Configuration
project_name = "adsmicrosite"
environment  = "dev"
location     = "Central US"

# GitHub Repository Configuration
github_repository_url = "https://github.com/duffney/ads-microsite"
github_branch         = "main"

# Resource Group (empty to use default naming)
resource_group_name = ""

# Static Web App Configuration
sku_tier = "Free"

# Custom Domain (empty for dev)
custom_domain_name = ""

# Tags
tags = {
  Project     = "ads-microsite"
  Environment = "development"
  ManagedBy   = "terraform"
  Purpose     = "marketing-microsite-dev"
  CostCenter  = "marketing"
  Owner       = "platform-team"
}
