
variable "ttl" {
  type        = number
  default     = 300
  description = "The TTL of the record"
}

variable "mx_providers_list" {
  type        = list(string)
  default     = []
  description = "A list of MX providers. Values: google, skymail"

  validation {
    condition     = alltrue([for mx_provider in var.mx_providers_list : can(regex("^(google|skymail)$", mx_provider))])
    error_message = "Invalid value for providers. Valid values: google, skymail"
  }
}

variable "spf_providers_list" {
  type        = list(string)
  default     = []
  description = "A list of SPF providers. Values: google, mcsv, skymail, sendgrid"

  validation {
    condition     = alltrue([for spf_provider in var.spf_providers_list : can(regex("^(google|mcsv|skymail|sendgrid)$", spf_provider))])
    error_message = "Invalid value for providers. Valid values: google, mcsv, skymail, sendgrid"
  }
}
