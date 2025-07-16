#!/bin/bash

set -e

# Configuration
PROJECT_NAME="adsmicrosite"
ENVIRONMENT="prod"
LOCATION="East US 2"
RESOURCE_GROUP_NAME="${PROJECT_NAME}-tfstate-${ENVIRONMENT}"
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tf${ENVIRONMENT}$(date +%s | tail -c 5)"
CONTAINER_NAME="tfstate"

# Create resource group
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION"

# Create storage account
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku "Standard_LRS" \
    --https-only true

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' -o tsv)

# Create blob container
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$STORAGE_KEY"

# Output backend configuration
echo "resource_group_name = \"$RESOURCE_GROUP_NAME\""
echo "storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "container_name = \"$CONTAINER_NAME\""

# Create service principal
az ad sp create-for-rbac --name "gh-actions-ads-microsite-terraform" \
  --role="Contributor" \
  --scopes="/subscriptions/{subscription-id}"

# Configure OIDC federation (replace {app-id} and {subscription-id})
az ad app federated-credential create \
  --id {app-id} \
  --parameters '{
    "name": "gh-actions-terraform-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:duffney/ads-microsite:ref:refs/heads/main",
    "description": "GitHub Actions Terraform deployment",
    "audiences": ["api://AzureADTokenExchange"]
  }'