locals {
  mx_providers = {
    google = [
      { value = "aspmx.l.google.com", priority = "1" },
      { value = "alt1.aspmx.l.google.com", priority = "5" },
      { value = "alt2.aspmx.l.google.com", priority = "5" },
      { value = "alt3.aspmx.l.google.com", priority = "10" },
      { value = "alt4.aspmx.l.google.com", priority = "10" },
    ]
    skymail = [
      { value = "mx-ha.skymail.net.br", priority = "1" }
    ]
  }
  mx_records = flatten([
    for provider in var.mx_providers_list : [
      for record in local.mx_providers[provider] : {
        name = "@", type = "MX", ttl = var.ttl, priority = record.priority, value = record.value
      }
    ]
  ])
}

output "records" {
  value = local.mx_records
}
