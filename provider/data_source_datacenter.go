package profitbricks

import (
	"github.com/hashicorp/terraform/helper/schema"
	"github.com/profitbricks/profitbricks-sdk-go"
	"fmt"
	"log"
	"strings"
)

func dataSourceDataCenter() *schema.Resource {
	return &schema.Resource{
		Read: dataSourceDataCenterRead,
		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
			},
			"location": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"id" : {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

func dataSourceDataCenterRead(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*Config)
	profitbricks.SetAuth(config.Username, config.Password)

	datacenters := profitbricks.ListDatacenters()

	if datacenters.StatusCode > 299 {
		return fmt.Errorf("An error occured while fetching datacenters %s", datacenters.Response)
	}

	name, _ := d.GetOk("name")
	location, locationOk := d.GetOk("location")

	results := []profitbricks.Datacenter{}

	for _, dc := range datacenters.Items {
		if dc.Properties.Name == name.(string) || strings.Contains(dc.Properties.Name, name.(string)) {
			results = append(results, dc)
		}
	}

	if locationOk {
		log.Printf("[INFO] searching dcs by location***********")
		locationResults := []profitbricks.Datacenter{}
		for _, dc := range results {
			if dc.Properties.Location == location.(string) {
				locationResults = append(locationResults, dc)
			}
		}
		results = locationResults
	}
	log.Printf("[INFO] Results length %d *************", len(results))

	if len(results) > 1 {
		log.Printf("[INFO] Results length greater than 1")
		return fmt.Errorf("There are more than 1 datacenters with provided search criteria")
	}

	d.SetId(results[0].Id)

	return nil
}
