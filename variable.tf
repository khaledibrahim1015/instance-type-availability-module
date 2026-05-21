
locals {
  const_opt_status = ["opt-in-not-required", "opted-in", "not-opted-in"]
}

variable "opt_in_status" {
  description = "Filter AZs by opt-in status. Use 'opt-in-not-required' for default AZs."
  type = list(string)
  default = [ "opt-in-not-required" ]
  validation {
    condition = alltrue([
        for s in var.opt_in_status : contains(local.const_opt_status, s)
    ])
    error_message = "Valid values are: opt-in-not-required, opted-in, not-opted-in."
  }
}



variable "instance_types" {
   description = "List of instance types to check for availability."
   type = list(string)
    default = ["t3.micro"]
    validation {
    condition = length(var.instance_types) > 0
    error_message = "At least one instance type must be specified."
    }
}