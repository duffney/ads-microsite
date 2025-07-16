# Static Web App - Essential Outputs
output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for GitHub Actions deployment"
  value       = azurerm_static_web_app.main.api_key
  sensitive   = true
}

output "github_repository_url" {
  description = "GitHub repository URL for deployment configuration"
  value       = var.github_repository_url
}

output "github_branch" {
  description = "GitHub branch for deployment"
  value       = var.github_branch
}
