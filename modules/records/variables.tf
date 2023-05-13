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
  default     = 300
  description = "The TTL of the record"

  validation {
    condition     = var.ttl >= 1 && var.ttl <= 2147483647
    error_message = "Invalid value for ttl. Must be between 1 and 2147483647."
  }
}

variable "records" {
  type = map(object({
    name     = string
    type     = string
    value    = string
    ttl      = optional(number)
    priority = optional(string)
    proxied  = optional(bool)
  }))
  description = "Map of objects that describe the zone record to add. Attention: if the record has no 'priority', let it but without value."

  // ... Validate name
  validation {
    condition     = alltrue([for record in var.records : false if record.name == ""])
    error_message = "Invalid value for name. It cannot be empty."
  }

  // ... Validate type
  validation {
    condition     = alltrue([for record in var.records : can(regex("^(A|AAAA|ALIAS|CNAME|MX|TXT)$", record.type))])
    error_message = "Invalid value for type. Valid values: A, AAAA, ALIAS, CNAME, MX, TXT"
  }

  validation {
    condition     = alltrue([for record in var.records : can(regex("^[1-9][0-9]{0,2}$", record.priority)) if record.type == "MX"])
    error_message = "Invalid value for priority when type MX. Must be a number between 0 and 999."
  }

  validation {
    condition     = alltrue([for record in var.records : can(regex("^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", record.value)) if record.type == "CNAME"])
    error_message = "Invalid value for value when type CNAME. Must be a valid FQDN."
  }

  // ... Validate value
  validation {
    condition     = alltrue([for record in var.records : false if record.value == ""])
    error_message = "Invalid value for value. It cannot be empty."
  }

  // ... Validate ttl
  validation {
    condition     = alltrue([for record in var.records : try(record.ttl >= 1 && record.ttl <= 2147483647, true)])
    error_message = "Invalid value for ttl. Must be a number between 1 and 2147483647."
  }

  // ... Validate priority
  validation {
    condition     = alltrue([for record in var.records : record.type == "MX" if try(record.priority, null) != null])
    error_message = "Invalid value for type when priority is specified. Must be MX."
  }
}
