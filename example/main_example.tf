provider "aws" {
  region = "us-east-1"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.micro"]
}




# ── Example 1: single instance type (most common) ───────────────────────────
module "t3_micro_azs" {
  source = "../" # points up to the module root

  instance_types = var.instance_types
}
output "region" {
  value = module.t3_micro_azs.region
}

output "t3_micro_supported_azs" {
  value = module.t3_micro_azs.supported_azs
}

# # ── Example 2: multiple types — find AZs that support all of them ────────────
# module "mixed_azs" {
#   source = "../"

#   instance_types = ["t3.micro", "c5.xlarge", "r5.2xlarge"]
# }

# output "azs_for_all_three_types" {
#   description = "Only AZs where you can launch any of the three types."
#   value       = module.mixed_azs.az_to_supported_types
# }

# output "per_type_availability" {
#   description = "Full breakdown of which types land in which AZs."
#   value       = module.mixed_azs.type_to_supported_azs
# }

# # ── Example 3: feed directly into aws_subnet resource ───────────────────────
# module "subnet_safe_azs" {
#   source         = "../"
#   instance_types = ["t3.micro"]
# }

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "app" {
#   # Only create subnets in AZs that actually support the instance type.
#   for_each = toset(module.subnet_safe_azs.supported_azs)

#   vpc_id            = aws_vpc.main.id
#   availability_zone = each.key
#   cidr_block        = cidrsubnet("10.0.0.0/16", 8, index(module.subnet_safe_azs.supported_azs, each.key))

#   tags = {
#     Name = "app-subnet-${each.key}"
#   }
# }
