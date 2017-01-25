package profitbricks

import (
	"github.com/hashicorp/terraform/helper/schema"
	"github.com/hashicorp/terraform/terraform"
	"github.com/profitbricks/profitbricks-sdk-go"
)

// Provider returns a schema.Provider for ProfitBricks.
func Provider() terraform.ResourceProvider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"username": {
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("PROFITBRICKS_USERNAME", nil),
				Description: "ProfitBricks username for API operations.",
			},
			"password": {
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("PROFITBRICKS_PASSWORD", nil),
				Description: "ProfitBricks password for API operations.",
			},
			"endpoint": {
				Type:        schema.TypeString,
				Optional:    true,
				DefaultFunc: schema.EnvDefaultFunc("PROFITBRICKS_API_URL", profitbricks.Endpoint),
				Description: "ProfitBricks REST API URL.",
			},
			"timeout": {
				Type:     schema.TypeInt,
				Optional: true,
			},
		},

		ResourcesMap: map[string]*schema.Resource{
			"profitbricks_datacenter":   resourceProfitBricksDatacenter(),
			"profitbricks_ipblock":      resourceProfitBricksIPBlock(),
			"profitbricks_firewall":     resourceProfitBricksFirewall(),
			"profitbricks_lan":          resourceProfitBricksLan(),
			"profitbricks_loadbalancer": resourceProfitBricksLoadbalancer(),
			"profitbricks_nic":          resourceProfitBricksNic(),
			"profitbricks_server":       resourceProfitBricksServer(),
			"profitbricks_volume":       resourceProfitBricksVolume(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"profitbricks_datacenter" : dataSourceDataCenter(),
			"profitbricks_location" : dataSourceLocation(),
			"profitbricks_image" : dataSourceImage(),
		},
		ConfigureFunc: providerConfigure,
	}
}

func providerConfigure(d *schema.ResourceData) (interface{}, error) {
	config := Config{
		Username: d.Get("username").(string),
		Password: d.Get("password").(string),
		Endpoint: d.Get("endpoint").(string),
		Timeout:  d.Get("timeout").(int),
	}
	return config.Client()
}
