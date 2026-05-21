package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestInstanceTypeAvailabilityModule(t *testing.T) {
	t.Parallel()

	opts := &terraform.Options{
		TerraformDir: "../examples",
		Vars: map[string]interface{}{
			"instance_types": []string{"t3.micro"},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	}

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	supportedAZs := terraform.OutputList(t, opts, "t3_micro_supported_azs")
	assert.Greater(t, len(supportedAZs), 0, "Expected at least one AZ supporting t3.micro")

	region := terraform.Output(t, opts, "region")
	assert.Equal(t, "us-east-1", region)
}
