package main

import (
	"github.com/profitbricks/terraform-provider-profitbricks/provider"
	"github.com/hashicorp/terraform/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: profitbricks.Provider,
	})
}
