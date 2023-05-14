locals {
  // --- Record fields ---
  // name     = string
  // type     = string
  // value    = optional(string)
  // ttl      = optional(number)
  // priority = optional(string)
  // proxied  = optional(bool)
  // alias = optional(object({
  //   name                   = string
  //   zone_id                = string
  //   evaluate_target_health = optional(bool)
  // }))
  records_tmp = {
    for record in var.records : record.type => {
      name     = record.name
      type     = record.type
      value    = record.value
      ttl      = try(record.ttl, var.ttl)
      priority = try(record.priority, null)
      proxied  = try(record.proxied, null)
      alias    = try(record.alias, null)
    }...
  }
  records = {
    for type, records in local.records_tmp : type => {
      for record in records : record.name => {
        name     = record.name
        type     = record.type
        value    = record.value
        ttl      = record.ttl
        priority = record.priority
        proxied  = record.proxied
        alias    = record.alias
      }...
    }
  }
  records_aws = {
    for type, names in local.records : type => {
      for name, records in names : name => {
        name  = name,
        type  = type,
        ttl   = element(sort([for record in records : record.ttl]), 0),
        alias = try(records[0].alias, null),
        value = [
          for record in records : type == "MX" ? "${record.priority} ${record.value}" : record.value
        ]
      }
    }
  }
}

output "records" {
  value = local.records
}

output "records_aws" {
  value = local.records_aws
}

output "validate_alias" {
  value = null

  precondition {
    condition = alltrue(flatten([
      for type, names in local.records : [
        for name, records in names : [
          for record in records : record.alias != null ? length(records) == 1 : true
        ]
      ]
    ]))
    error_message = "If a record is an alias, it must be the only record for that name."
  }
}
