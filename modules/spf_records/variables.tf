variable "name" {
  type        = string
  description = "The FQDN for the zone"

  validation {
    condition     = can(regex("^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "Invalid value for name. Must be a valid FQDN."
  }
}

variable "ttl" {
  type        = number
  default     = null
  description = "The TTL of the record"

  validation {
    condition     = try(var.ttl, null) != null ? (var.ttl >= 1 && var.ttl <= 2147483647) : true
    error_message = "Invalid value for ttl. Must be between 1 and 2147483647 or null."
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
