
provider "aws" {
   region = "us-east-1" 
}


# This file is used to define the main configuration for the AWS instance type availability module.

#  data source to retrieve the current AWS region.
data "aws_region" "current-region" {}

# Get list of availabilty zones in the current region.
data "aws_availability_zones" "availability-azs" {
    region = data.aws_region.current-region.name
    filter {
        name   = "opt-in-status" 
        values = var.opt_in_status # Filter to include only availability zones that do not require opt-in.
    }  
}

