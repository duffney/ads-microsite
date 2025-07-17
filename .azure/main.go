package main

import (
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/applicationinsights"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/provider"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/resourcegroup"
	"github.com/cdktf/cdktf-provider-azurerm-go/azurerm/v14/staticwebapp"
	"github.com/hashicorp/terraform-cdk-go/cdktf"
)

func NewMyStack(scope constructs.Construct, id string, config Config) cdktf.TerraformStack {
	stack := cdktf.NewTerraformStack(scope, &id)

	provider.NewAzurermProvider(stack, jsii.String("azurerm"), &provider.AzurermProviderConfig{
		Features: []*provider.AzurermProviderFeatures{{}},
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
		Identity: &staticwebapp.StaticWebAppIdentity{
			Type: jsii.String("SystemAssigned"),
		},
	})

	appInsights := applicationinsights.NewApplicationInsights(stack, jsii.String("MyApplicationInsights"), &applicationinsights.ApplicationInsightsConfig{
		ResourceGroupName: rg.Name(),
		Location:          jsii.String(config.ApplicationInsights.Location),
		Name:              jsii.String(config.ApplicationInsights.Name),
		RetentionInDays:   jsii.Number(config.ApplicationInsights.RetentionInDays),
		Tags:              config.Tags,
	})

	cdktf.NewTerraformOutput(stack, jsii.String("static_web_app_name"), &cdktf.TerraformOutputConfig{
		Value:       swa.Name(),
		Description: jsii.String("The name of the static web app"),
	})

	return stack
}

func main() {
	app := cdktf.NewApp(nil)

	config := GetEnvironmentConfig("dev")

	NewMyStack(app, "adsMicrosite", config)

	app.Synth()
}
