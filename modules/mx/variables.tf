variable "mx_providers_list" {
  type        = list(string)
  default     = []
  description = "A list of MX providers. Values: google, skymail"

  validation {
    condition     = alltrue([for mx_provider in var.mx_providers_list : can(regex("^(google|skymail)$", mx_provider))])
    error_message = "Invalid value for providers. Valid values: google, skymail"
  }
}

variable "ttl" {
  type        = number
  default     = 300
  description = "The TTL of the record"
}
