locals {
  name_regex = "^.{0,}(\\.|)${replace(var.name, ".", "\\.")}$"
  records = [
    for r in var.records : {
      name     = r.name == "@" ? var.name : can(regex(local.name_regex, r.name)) ? r.name : "${r.name}.${var.name}"
      type     = r.type
      value    = r.value == "@" ? var.name : r.value
      ttl      = r.ttl != null ? r.ttl : var.ttl
      priority = try(r.priority, null)
      proxied  = try(r.proxied, null)
      alias    = try(r.alias, null)
    }
  ]
}

output "records" {
  value = local.records
}
