package profitbricks

import (
	"github.com/profitbricks/profitbricks-sdk-go"
)

type Config struct {
	Username string
	Password string
	Endpoint string
	Timeout  int
}

// Client() returns a new client for accessing profitbricks
func (c *Config) Client() (*Config, error) {
	profitbricks.SetAuth(c.Username, c.Password)
	profitbricks.SetDepth("5")
	if len(c.Endpoint)>0{
		profitbricks.SetEndpoint(c.Endpoint)
	}

	return c, nil
}
