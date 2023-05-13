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
  spf_records = [{
    name  = "@",
    type  = "TXT",
    ttl   = var.ttl,
    value = join(" ", concat(["v=spf1"], local.spf_selected_providers, ["~all"]))
  }]
}

output "records" {
  value = local.spf_records
}
