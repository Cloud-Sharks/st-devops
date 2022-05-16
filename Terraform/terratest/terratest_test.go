package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformPlanApply(t *testing.T) {

	// runs in parallel if we have multiple tests
	t.Parallel()

	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	// Destroys resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	my_VPCName := terraform.Output(t, terraformOptions, "my_vpc")
	t.Logf("VPC Name: %s", my_VPCName)
	assert.Equal(t, ExpectedValues.VpcName, my_VPCName)

	// VPC_Cidr := terraform.Output(t, terraformOptions, "main_vpc_cidr")
	// t.Logf("VPC Name: %s", my_VPC_CIDR)



}

