
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

