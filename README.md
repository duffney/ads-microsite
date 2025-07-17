# Azure Static Web Apps Microsite

A production-ready marketing microsite built with Azure Static Web Apps, featuring global CDN distribution, comprehensive monitoring, and Infrastructure as Code deployment.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   GitHub Repo   │    │  GitHub Actions  │    │    Azure Cloud      │
│                 │    │                  │    │                     │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ ┌─────────────────┐ │
│ │HTML/CSS/JS  │ │───▶│ │  Terraform   │ │───▶│ │ Static Web App  │ │
│ │staticwebapp │ │    │ │  Validation  │ │    │ │   (Free Tier)   │ │
│ │   config    │ │    │ │  & Deploy    │ │    │ │  Global CDN     │ │
│ └─────────────┘ │    │ └──────────────┘ │    │ └─────────────────┘ │
└─────────────────┘    └──────────────────┘    │                     │
                                               │ ┌─────────────────┐ │
┌─────────────────┐    ┌──────────────────┐    │ │App Insights     │ │
│ Global Users    │    │   Monitoring     │    │ │- US/EU Tests    │ │
│                 │    │                  │    │ │- Response Time  │ │
│ 🇺🇸 North America │◀───│ Availability:95% │◀───│ │- Availability   │ │
│ 🇪🇺 Europe        │    │ Response: <1.5s  │    │ │- Alerts         │ │
└─────────────────┘    └──────────────────┘    │ └─────────────────┘ │
                                               └─────────────────────┘
```

## Cost Calculation

| Service                                 | SKU           | Monthly Cost | Assumptions                          |
| --------------------------------------- | ------------- | ------------ | ------------------------------------ |
| **Static Web App**                      | Free          | $0.00        | 100GB bandwidth, 0.5GB storage       |
| **Application Insights Data Ingestion** | Pay-as-you-go | ~$1.46       | 5GB data ingestion, 90-day retention |
| **Availability Tests**                  | Standard      | ~$1.65       | 2 locations × 2,880 tests/month      |
| **Storage Account** (Terraform state)   | Standard LRS  | ~$0.50       | 1GB state files                      |

**Total Estimated Cost: ~$3.61/month** ✅

Costs estimated with [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/).

### Assumptions

- **Traffic**: Low marketing site traffic (<10K visits/month)
- **Monitoring**: 5-minute test frequency from 2 global locations
- **Data Retention**: 30 days for Application Insights and availability data
- **Free Tier Benefits**: Static Web Apps free tier covers typical marketing site needs

## Operational Considerations

### 🔒 Security

- **HTTPS + Security Headers**: CSP, HSTS, X-Frame-Options enforced via Azure Static Web Apps
- **OIDC Authentication**: Passwordless GitHub Actions deployment with Azure integration
- **Secrets Management**: GitHub Secrets for sensitive values (Azure credentials, API keys)

### 🛡️ Resilience

- **Global CDN**: Azure's worldwide distribution with 99.95% SLA
- **Multi-Region Testing**: Availability monitoring from US West and EU Amsterdam
- **Infrastructure as Code**: Rapid redeployment and Git-based rollback capability

### 📊 Observability

- **Performance Monitoring**: <1.5s response time alerts and 95% availability thresholds
- **Global Coverage**: Synthetic tests from North America and Europe every 5 minutes
- **Centralized Dashboards**: Application Insights with Azure Monitor alert integration

## Repository Structure

```
├── infrastructure/          # Terraform configuration
├── css/                    # Stylesheet files
├── js/                     # JavaScript application logic
├── staticwebapp.config.json # Azure SWA configuration + security
├── index.html              # Main landing page
└── .github/workflows/      # CI/CD pipeline
```

---
