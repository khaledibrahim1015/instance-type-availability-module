output "current_region" {
 value = data.aws_region.current-region.name 
}

output "all_azs" {
    description = "All availability zones found in the region (before filtering by instance support)."
    value = data.aws_availability_zones.available.names
}


output "az_to_supported_types" {
  description = <<-EOT
    Map of AZ → list of supported instance types from the requested set.
    AZs that support none of the requested types still appear with an empty list.
    Example: { "us-east-1a" = ["t3.micro"], "us-east-1e" = [] }
  EOT
  value = local.az_to_supported_types
}

output "type_to_supported_azs" {
  description = <<-EOT
    Inverse map of instance_type → list of AZs where it is available.
    Example: { "t3.micro" = ["us-east-1a", "us-east-1b", "us-east-1c"] }
  EOT
  value = local.type_to_supported_azs
}


# Convenience outputs for the single-type common case
output "supported_azs" {
  description = <<-EOT
    Flat list of AZs supporting at least one of the requested instance types.
    For multi-type queries, prefer azs_supporting_all_types.
  EOT
  value = distinct(flatten([for azs in local.type_to_supported_azs : azs]))
}
