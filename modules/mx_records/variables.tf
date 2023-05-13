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

variable "mx_provider" {
  type        = string
  description = "The MX provider. Valid values: google, skymail"

  validation {
    condition     = can(regex("^(google|skymail)$", var.mx_provider))
    error_message = "Invalid value for provider. Valid values: google, skymail"
  }
}
