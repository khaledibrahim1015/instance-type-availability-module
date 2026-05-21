
# provider "aws" {
#    region = "us-east-1" 
# }


# This file is used to define the main configuration for the AWS instance type availability module. It includes data sources to retrieve the current AWS region and the availability zones in that region, filtered by opt-in status. The outputs provide the current region and the list of availability zones found. The module is designed to be flexible, allowing users to specify which opt-in statuses to include when filtering availability zones.
#  data source to retrieve the current AWS region.
data "aws_region" "current-region" {}

# Get list of availabilty zones in the current region.
data "aws_availability_zones" "available" {
    region = data.aws_region.current-region.name
    filter {
        name   = "opt-in-status" 
        values = var.opt_in_status # Filter to include only availability zones that do not require opt-in.
    }  
}


# Check if that respective Instance Type is supported in that Specific Region in list of availability Zones
# Get the List of Availability Zones in a Particular region where that respective Instance Type is supported
# for_each = toset(data.aws_availability_zones.available.names)
# terraform will loop through the list of availability zones and check if that respective instance type is supported in that availability zone or not and return the list of availability zones where that respective instance type is supported
# and create a map of availability zones and the respective instance type offerings in that availability zone
#  {
#   "us-east-1a" = <data object>
#   "us-east-1b" = <data object>
#   "us-east-1c" = <data object>
# }


 # For each combination of (AZ, instance_type), query AWS for offering support.
 # Key format: "<az>|<instance_type>" keeps the map flat and avoids nested for_each.
locals {

  # Cartesian product: az × instance_type
  az_instance_pairs = {
    # example output : "us-east-1a|t3.micro" => { az = "us-east-1a", instance_type = "t3.micro" }
    for pair in setproduct(
      data.aws_availability_zones.available.names,
      var.instance_types
    ) : "${pair[0]}|${pair[1]}" => { az = pair[0], instance_type = pair[1] }
  }
}

data "aws_ec2_instance_type_offerings" "this" {
    for_each = local.az_instance_pairs
    location_type = "availability-zone"
    filter {
        name   = "instance-type"
        values = [each.value.instance_type]
     }
    filter {
        name   = "location"
        values = [each.value.az]
    }
}


locals {
  # Flatten results into a readable map:
  # { "us-east-1a" = ["t3.micro", "t3.small"], "us-east-1b" = ["t3.micro"], ... }
   
   az_to_supported_types  = {
    for az in data.aws_availability_zones.available.names : az => [
        for instance_type in var.instance_types : instance_type
        if length(data.aws_ec2_instance_type_offerings.this["${az}|${instance_type}"].instance_types) > 0
    ]
   }

    # Inverse map: { "t3.micro" = ["us-east-1a", "us-east-1b", ...], ... }
    type_to_supported_azs = {
        for instance_type in var.instance_types : instance_type => [
        for az in data.aws_availability_zones.available.names :
            az
        if length(data.aws_ec2_instance_type_offerings.this["${az}|${instance_type}"].instance_types) > 0
        ]
    }

   # AZs that support ALL requested instance types (useful for subnet placement)
    azs_supporting_all_types = [
        for az, types in local.az_to_supported_types :
        az
        if length(types) == length(var.instance_types)
    ]
}