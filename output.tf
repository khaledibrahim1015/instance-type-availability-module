output "current_region" {
 value = data.aws_region.current-region.name 
}

output "all_azs" {
    description = "All availability zones found in the region (before filtering by instance support)."
    value = data.aws_availability_zones.availability-azs.names
}


