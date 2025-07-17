package main

import (
	"fmt"
	"os"

	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/applicationinsights"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/applicationinsightswebtest"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/monitoractiongroup"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/monitormetricalert"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/provider"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/resourcegroup"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/staticwebapp"
	"github.com/hashicorp/terraform-cdk-go/cdktf"
)

func NewMyStack(scope constructs.Construct, id string, config Config) cdktf.TerraformStack {
	stack := cdktf.NewTerraformStack(scope, &id)

	provider.NewAzurermProvider(stack, jsii.String("azurerm"), &provider.AzurermProviderConfig{
		Features: []*provider.AzurermProviderFeatures{{
			// Removed unknown field prevent_deletion_if_contains_resources
		}},
	})

	rg := resourcegroup.NewResourceGroup(stack, jsii.String("MyResourceGroup"), &resourcegroup.ResourceGroupConfig{
		Name:     jsii.String(config.ResourceGroup.Name),
		Location: jsii.String(config.ResourceGroup.Location),
	})

	swa := staticwebapp.NewStaticWebApp(stack, jsii.String("MyStaticWebApp"), &staticwebapp.StaticWebAppConfig{
		ResourceGroupName: rg.Name(),
		Location:          jsii.String(config.StaticWebApp.Location),
		Name:              jsii.String(config.StaticWebApp.Name),
		SkuTier:           jsii.String(config.StaticWebApp.SkuTier),
		Tags:              config.Tags,
	})

	appInsights := applicationinsights.NewApplicationInsights(stack, jsii.String("MyApplicationInsights"), &applicationinsights.ApplicationInsightsConfig{
		ResourceGroupName: rg.Name(),
		Location:          jsii.String(config.ApplicationInsights.Location),
		Name:              jsii.String(config.ApplicationInsights.Name),
		RetentionInDays:   jsii.Number(config.ApplicationInsights.RetentionInDays),
		ApplicationType:   jsii.String(config.ApplicationInsights.ApplicationType),
		Tags:              config.Tags,
	})

	applicationinsightswebtest.NewApplicationInsightsWebTest(stack, jsii.String("GlobalMonitorWebTest"), &applicationinsightswebtest.ApplicationInsightsWebTestConfig{
		Name:                  jsii.String(config.ResourceNames.WebTest),
		Location:              jsii.String(config.ResourceGroup.Location),
		ResourceGroupName:     rg.Name(),
		ApplicationInsightsId: appInsights.Id(),
		Kind:                  jsii.String("ping"),
		Frequency:             jsii.Number(config.MonitoringConfig.Frequency),
		Timeout:               jsii.Number(config.MonitoringConfig.Timeout),
		Enabled:               jsii.Bool(true),
		GeoLocations:          jsii.Strings(config.MonitoringConfig.GeoLocations...),
		Configuration: jsii.String(fmt.Sprintf(`
<WebTest Name="%s" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="%d" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
		<Items>
				<Request Method="GET" Version="1.1" Url="%s" ThinkTime="0" Timeout="%d" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
		</Items>
</WebTest>
`, config.ResourceNames.WebTest, config.MonitoringConfig.Timeout, config.StaticWebApp.Url, config.MonitoringConfig.Timeout)),
		Tags: config.Tags,
	})

	actionGroup := monitoractiongroup.NewMonitorActionGroup(stack, jsii.String("AlertsActionGroup"), &monitoractiongroup.MonitorActionGroupConfig{
		Name:              jsii.String(config.ActionGroup.Name),
		ResourceGroupName: rg.Name(),
		ShortName:         jsii.String(config.ActionGroup.ShortName),
		EmailReceiver: &[]*monitoractiongroup.MonitorActionGroupEmailReceiver{
			{
				Name:         jsii.String("admin"),
				EmailAddress: jsii.String(config.AdminEmail),
			},
		},
		Tags: config.Tags,
	})

	monitormetricalert.NewMonitorMetricAlert(stack, jsii.String("AvailabilityAlert"), &monitormetricalert.MonitorMetricAlertConfig{
		Name:              jsii.String(config.AvailabilityAlert.Name),
		ResourceGroupName: rg.Name(),
		Scopes:            &[]*string{appInsights.Id()},
		Description:       jsii.String(config.AvailabilityAlert.Description),
		Criteria: &[]*monitormetricalert.MonitorMetricAlertCriteria{
			{
				MetricNamespace: jsii.String("Microsoft.Insights/components"),
				MetricName:      jsii.String("availabilityResults/availabilityPercentage"),
				Aggregation:     jsii.String("Average"),
				Operator:        jsii.String("LessThan"),
				Threshold:       jsii.Number(config.AvailabilityAlert.AvailabilityThreshold),
			},
		},
		Action: &[]*monitormetricalert.MonitorMetricAlertAction{
			{
				ActionGroupId: actionGroup.Id(),
			},
		},
		Frequency:  jsii.String(config.AvailabilityAlert.Frequency),
		WindowSize: jsii.String(config.AvailabilityAlert.WindowSize),
		Severity: jsii.Number(func() int {
			if os.Getenv("NODE_ENV") == "prod" {
				return config.AvailabilityAlert.SeverityProd
			}
			return config.AvailabilityAlert.SeverityNonProd
		}()),
		Tags:      config.Tags,
		DependsOn: &[]cdktf.ITerraformDependable{actionGroup},
	})

	monitormetricalert.NewMonitorMetricAlert(stack, jsii.String("ResponseTimeAlert"), &monitormetricalert.MonitorMetricAlertConfig{
		Name:              jsii.String(config.ResponseTimeAlert.Name),
		ResourceGroupName: rg.Name(),
		Scopes:            &[]*string{appInsights.Id()},
		Description:       jsii.String(config.ResponseTimeAlert.Description),
		Criteria: &[]*monitormetricalert.MonitorMetricAlertCriteria{
			{
				MetricNamespace: jsii.String("Microsoft.Insights/components"),
				MetricName:      jsii.String("availabilityResults/duration"),
				Aggregation:     jsii.String("Average"),
				Operator:        jsii.String("GreaterThan"),
				Threshold:       jsii.Number(config.ResponseTimeAlert.ResponseTimeThreshold),
			},
		},
		Action: &[]*monitormetricalert.MonitorMetricAlertAction{
			{
				ActionGroupId: actionGroup.Id(),
			},
		},
		Frequency:  jsii.String(config.ResponseTimeAlert.Frequency),
		WindowSize: jsii.String(config.ResponseTimeAlert.WindowSize),
		Severity: jsii.Number(func() int {
			if os.Getenv("NODE_ENV") == "prod" {
				return config.ResponseTimeAlert.SeverityProd
			}
			return config.ResponseTimeAlert.SeverityNonProd
		}()),
		Tags:      config.Tags,
		DependsOn: &[]cdktf.ITerraformDependable{actionGroup},
	})

	cdktf.NewTerraformOutput(stack, jsii.String("static_web_app_name"), &cdktf.TerraformOutputConfig{
		Value:       swa.Name(),
		Description: jsii.String("The name of the static web app"),
	})

	// output action group ID
	cdktf.NewTerraformOutput(stack, jsii.String("action_group_id"), &cdktf.TerraformOutputConfig{
		Value:       actionGroup.Id(),
		Description: jsii.String("The ID of the action group for alerts"),
	})

	return stack
}

func main() {
	app := cdktf.NewApp(nil)

	config := GetEnvironmentConfig("dev")

	NewMyStack(app, "adsMicrosite", config)

	app.Synth()
}
