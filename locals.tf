locals {
  // SPF
  spf_defaults = {
    sendgrid = "include:sendgrid.net",
    skymail  = "include:spf.skymail.net.br",
    mcsv     = "include:servers.mcsv.net",
    google   = "include:_spf.google.com",
  }
  spf_tmp = [
    for provider in var.spf_providers : local.spf_defaults[provider]
  ]
  spf = join(" ", concat(["v=spf1"], local.spf_tmp, ["~all"]))
  // MX
  mx_defaults = {
    google = [
      { name = "aspmx.l.google.com", priority = "1" },
      { name = "alt1.aspmx.l.google.com", priority = "5" },
      { name = "alt2.aspmx.l.google.com", priority = "5" },
      { name = "alt3.aspmx.l.google.com", priority = "10" },
      { name = "alt4.aspmx.l.google.com", priority = "10" },
    ]
    skymail = [
      { name = "mx-ha.skymail.net.br", value = "1" }
    ]
  }
  // Records
  records_tmp = {
    for record in var.records : record.type => {
      value = record.value
      name  = record.name
    }...
  }
  records = {
    for type, records in local.records_tmp : type => {
      for record in records : record.name => record.value...
    }
  }
}
