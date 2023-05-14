locals {
  name_regex = replace(var.name, ".", "\\.")
  records = {
    for k, v in var.records : k => {
      name     = can(regex("^.{0,}(\\.|)${local.name_regex}$", v.name)) ? v.name : "${v.name}.${var.name}"
      type     = v.type
      value    = v.value
      ttl      = v.ttl != null ? v.ttl : var.ttl
      priority = try(v.priority, null)
      proxied  = try(v.proxied, null)
      alias    = try(v.alias, null)
    }
  }
}

output "records" {
  value = local.records
}
