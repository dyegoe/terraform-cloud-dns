locals {
  name_regex = "^.{0,}(\\.|)${replace(var.name, ".", "\\.")}$"
  records_by_type = {
    for r in var.records : r.type => {
      name     = r.name == "@" ? var.name : can(regex(local.name_regex, r.name)) ? r.name : "${r.name}.${var.name}"
      type     = r.type
      value    = r.value == "@" ? var.name : r.value
      ttl      = r.ttl != null ? r.ttl : var.ttl
      priority = try(r.priority, null)
      proxied  = try(r.proxied, null)
      alias    = try(r.alias, null)
    }...
  }
  records_by_type_and_name = {
    for t, records in local.records_by_type : t => {
      for r in records : r.name => {
        name     = r.name
        type     = r.type
        value    = r.value
        ttl      = r.ttl
        priority = r.priority
        proxied  = r.proxied
        alias    = r.alias
      }...
    }
  }
  records = {
    for type, names in local.records_by_type_and_name : type => {
      for name, records in names : name => {
        name  = name,
        type  = type,
        ttl   = element(sort([for r in records : r.ttl]), 0),
        alias = try(records[0].alias, null),
        value = [for r in records : type == "MX" ? "${r.priority} ${r.value}" : r.value]
      }
    }
  }
}

// --- Validate records ---
output "validate_alias" {
  value = null

  precondition {
    condition = alltrue(flatten([
      for type, names in local.records_by_type_and_name : [
        for name, records in names : [
          for r in records : r.alias != null ? length(records) == 1 : true
        ]
      ]
    ]))
    error_message = "If a record is an alias, it must be the only record for that name."
  }
}

// --- Create zone ---
resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.name
}

data "aws_route53_zone" "this" {
  count = var.create_zone ? 0 : 1
  name  = var.name
}
