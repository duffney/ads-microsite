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
}

type ResourceGroup struct {
	Name     string `json:"name"`
	Location string `json:"location"`
}

type StaticWebApp struct {
	Name     string `json:"name"`
	Location string `json:"location"`
	SkuTier  string `json:"skuTier"`
}

type ApplicationInsights struct {
	Name            string `json:"name"`
	Location        string `json:"location"`
	RetentionInDays int    `json:"retentionInDays"`
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
			Name:     fmt.Sprintf("ads-microsite-%s-rg", environment),
			Location: "East US", // You may want to make this configurable
		},
		StaticWebApp: StaticWebApp{
			Name:     fmt.Sprintf("ads-microsite-%s-swa", environment),
			Location: "East US", // You may want to make this configurable
			SkuTier:  "Free",    // You may want to make this configurable
		},
		ApplicationInsights: ApplicationInsights{
			Name:            fmt.Sprintf("ads-microsite-%s-ai", environment),
			Location:        "East US", // You may want to make this configurable
			RetentionInDays: 30,        // You may want to make this configurable
		},
		Tags: &map[string]*string{
			"Project":   jsii.String("ads-microsite"),
			"ManagedBy": jsii.String("terraform-cdk"),
		},
	}
}
