locals {
  spf_providers = {
    sendgrid = "include:sendgrid.net",
    skymail  = "include:spf.skymail.net.br",
    mcsv     = "include:servers.mcsv.net",
    google   = "include:_spf.google.com",
  }
  spf_selected_providers = [
    for spf_provider in var.spf_providers_list : local.spf_providers[spf_provider]
  ]
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
  spf_records = {
    spf1 = {
      name  = var.name,
      type  = "TXT",
      value = join(" ", concat(["v=spf1"], local.spf_selected_providers, ["~all"]))
      ttl   = var.ttl,
    }
  }
}

output "records" {
  value = local.spf_records
}
