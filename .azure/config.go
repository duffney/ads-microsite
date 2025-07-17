package main

import (
	"fmt"
	"os"

	"github.com/aws/jsii-runtime-go"
)

type Config struct {
	Tags                *map[string]*string `json:"tags"`
	ResourceGroup       ResourceGroup       `json:"resourceGroup"`
	StaticWebApp        StaticWebApp        `json:"staticWebApp"`
	ApplicationInsights ApplicationInsights `json:"applicationInsights"`
	MonitoringConfig    MonitoringConfig    `json:"monitoringConfig"`
	ResourceNames       ResourceNames       `json:"resourceNames"`
	ActionGroup         ActionGroup         `json:"actionGroup"`
	AdminEmail          string              `json:"adminEmail"`
	AvailabilityAlert   AvailabilityAlert   `json:"availabilityAlert"`
	ResponseTimeAlert   ResponseTimeAlert   `json:"responseTimeAlert"`
}

type MonitoringConfig struct {
	Frequency    int      `json:"frequency"`
	Timeout      int      `json:"timeout"`
	GeoLocations []string `json:"geoLocations"`
}

type ResourceNames struct {
	WebTest string `json:"webTest"`
}

type ResourceGroup struct {
	Name     string `json:"name"`
	Location string `json:"location"`
}

type AvailabilityAlert struct {
	Name                  string  `json:"name"`
	Description           string  `json:"description"`
	AvailabilityThreshold float64 `json:"availabilityThreshold"`
	Frequency             string  `json:"frequency"`
	WindowSize            string  `json:"windowSize"`
	SeverityProd          int     `json:"severityProd"`
	SeverityNonProd       int     `json:"severityNonProd"`
}

type ResponseTimeAlert struct {
	Name                  string  `json:"name"`
	Description           string  `json:"description"`
	ResponseTimeThreshold float64 `json:"responseTimeThreshold"`
	Frequency             string  `json:"frequency"`
	WindowSize            string  `json:"windowSize"`
	SeverityProd          int     `json:"severityProd"`
	SeverityNonProd       int     `json:"severityNonProd"`
}

type ActionGroup struct {
	Name      string `json:"name"`
	ShortName string `json:"shortName"`
}

type StaticWebApp struct {
	Name     string `json:"name"`
	Location string `json:"location"`
	SkuTier  string `json:"skuTier"`
	Url      string `json:"url"`
}

type ApplicationInsights struct {
	Name            string `json:"name"`
	Location        string `json:"location"`
	RetentionInDays int    `json:"retentionInDays"`
	ApplicationType string `json:"applicationType"`
}

// GetEnvironmentConfig returns configuration based on environment variable
func GetEnvironmentConfig(environment string) Config {
	// Get environment from environment variable, default to "dev"
	environment = os.Getenv("NODE_ENV")
	if environment == "" {
		environment = "dev"
	}
	return Config{
		ResourceGroup: ResourceGroup{
			Name:     fmt.Sprintf("ads-microsite-%s-rg-cdk", environment),
			Location: "eastus2",
		},
		StaticWebApp: StaticWebApp{
			Name:     fmt.Sprintf("ads-microsite-%s-swa", environment),
			Location: "eastus2",
			SkuTier:  "Free",
			Url:      "https://ads-microsite-example.azurestaticapps.net", // Example URL
		},
		ApplicationInsights: ApplicationInsights{
			Name:            fmt.Sprintf("ads-microsite-%s-ai", environment),
			Location:        "eastus2",
			RetentionInDays: 30,
			ApplicationType: "web",
		},
		MonitoringConfig: MonitoringConfig{
			Frequency:    300, // 5 minutes
			Timeout:      30,
			GeoLocations: []string{"us-fl-mia-edge"},
		},
		ResourceNames: ResourceNames{
			WebTest: "ads-microsite-global-monitor",
		},
		ActionGroup: ActionGroup{
			Name:      "ads-microsite-alerts",
			ShortName: "alerts",
		},
		AdminEmail: "admin@example.com",
		AvailabilityAlert: AvailabilityAlert{
			Name:                  "ads-microsite-availability-alert",
			Description:           "Alert when ads-microsite availability drops below 99%",
			AvailabilityThreshold: 99,
			Frequency:             "PT1M",
			WindowSize:            "PT5M",
			SeverityProd:          1,
			SeverityNonProd:       2,
		},
		ResponseTimeAlert: ResponseTimeAlert{
			Name:                  "ads-microsite-response-time-alert",
			Description:           "Alert when ads-microsite response time exceeds 1000ms",
			ResponseTimeThreshold: 1000,
			Frequency:             "PT1M",
			WindowSize:            "PT5M",
			SeverityProd:          2,
			SeverityNonProd:       3,
		},
		Tags: &map[string]*string{
			"Project":   jsii.String("ads-microsite"),
			"ManagedBy": jsii.String("terraform-cdk"),
		},
	}
}
