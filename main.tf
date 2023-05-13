locals {
  // ... MX records
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

  // ... SPF records
  spf_providers = {
    sendgrid = "include:sendgrid.net",
    skymail  = "include:spf.skymail.net.br",
    mcsv     = "include:servers.mcsv.net",
    google   = "include:_spf.google.com",
  }
  spf_selected_providers = [
    for spf_provider in var.spf_providers_list : local.spf_providers[spf_provider]
  ]
  spf_records = [{
    name  = "@",
    type  = "TXT",
    ttl   = var.ttl,
    value = join(" ", concat(["v=spf1"], local.spf_selected_providers, ["~all"]))
  }]
}
