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

| Service                               | SKU           | Monthly Cost | Assumptions                          |
| ------------------------------------- | ------------- | ------------ | ------------------------------------ |
| **Static Web App**                    | Free          | $0.00        | 100GB bandwidth, 0.5GB storage       |
| **Application Insights**              | Pay-as-you-go | ~$1.00       | 5GB data ingestion, 90-day retention |
| **Availability Tests**                | Standard      | ~$1.20       | 2 locations × 2,880 tests/month      |
| **Storage Account** (Terraform state) | Standard LRS  | ~$0.50       | 1GB state files                      |

**Total Estimated Cost: ~$2.70/month** ✅

### Assumptions

- **Traffic**: Low marketing site traffic (<10K visits/month)
- **Monitoring**: 5-minute test frequency from 2 global locations
- **Data Retention**: 30 days for Application Insights and availability data
- **Free Tier Benefits**: Static Web Apps free tier covers typical marketing site needs

## Operational Considerations

### 🔒 Security

- **HTTPS Everywhere**: Enforced via Static Web Apps platform
- **Security Headers**: CSP, HSTS, X-Frame-Options, Referrer-Policy configured
- **OIDC Authentication**: Passwordless GitHub Actions deployment
- **Secrets Management**: Azure Key Vault integration ready (currently using GitHub Secrets)
- **Infrastructure Scanning**: Trivy security scans in CI/CD pipeline

### 🛡️ Resilience

- **Global CDN**: Automatic worldwide distribution via Azure CDN
- **99.95% SLA**: Static Web Apps service level agreement
- **Multi-Region Testing**: Availability monitoring from US West and EU Amsterdam
- **Automated Recovery**: Infrastructure as Code enables rapid redeployment
- **Rollback Capability**: Git-based deployments with instant rollback

### 📊 Observability

- **Availability Monitoring**: 95% uptime threshold with 5-minute checks
- **Performance Monitoring**: <1.5 second response time alerts
- **Global Coverage**: Synthetic tests from North America and Europe
- **Alert Integration**: Azure Monitor alerts (ready for email/Slack integration)
- **Metrics Dashboard**: Application Insights portal for operational visibility

### 🚀 Day 2 Operations

- **Infrastructure as Code**: Fully automated Terraform deployment
- **CI/CD Pipeline**: GitHub Actions with validation, security scanning, and deployment
- **Monitoring**: Application Insights with configurable alerting
- **Security**: Automated security scanning with Trivy
- **Documentation**: Comprehensive README with architecture and costs
- **Handoff Ready**: New team members can understand and operate the system

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
