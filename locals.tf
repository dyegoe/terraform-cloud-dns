locals {
  // SPF -----------------------------------------------------------------------
  spf_defaults = {
    sendgrid = "include:sendgrid.net",
    skymail  = "include:spf.skymail.net.br",
    mcsv     = "include:servers.mcsv.net",
    google   = "include:_spf.google.com",
  }
  spf_tmp = [
    for provider in var.spf_providers : local.spf_defaults[provider]
  ]
  spf = [{
    name  = "@",
    type  = "TXT",
    ttl   = var.ttl_default,
    value = join(" ", concat(["v=spf1"], local.spf_tmp, ["~all"]))
  }]

  // MX ------------------------------------------------------------------------
  mx_defaults = {
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
    for provider in var.mx_providers : [
      for record in local.mx_defaults[provider] : {
        name     = "@"
        type     = "MX"
        ttl      = var.ttl_default
        priority = record.priority
        value    = record.value
      }
    ]
  ])

  // A root --------------------------------------------------------------------
  a_root = [{
    name  = "@",
    type  = "A",
    ttl   = var.ttl_default,
    value = var.a_root
  }]

  // CNAME www to root ---------------------------------------------------------
  cname_www = var.cname_www ? [{
    name  = "www",
    type  = "CNAME",
    ttl   = var.ttl_default,
    value = "@"
  }] : []

  // Records -------------------------------------------------------------------
  records_merge = concat(var.records, local.mx_records, local.spf, local.a_root)
  # { name = "@", type = "TXT", ttl = "300", priority = null, value = "value" },
  records_tmp = {
    for record in local.records_merge : record.type => {
      name     = record.name == "@" ? var.name : record.name
      ttl      = try(record.ttl, var.ttl_default)
      priority = try(record.priority, null)
      value    = record.value == "@" ? var.name : record.value
    }...
  }
  records = {
    for type, records in local.records_tmp : type => {
      for record in records : record.name => {
        value    = record.value
        ttl      = record.ttl
        priority = record.priority
      }...
    }
  }
  records_aws = {
    for type, names in local.records : type => {
      for name, records in names : name => {
        name = name,
        type = type,
        ttl  = element(sort([for record in records : record.ttl]), 0),
        value = [
          for record in records : type == "MX" ? "${record.priority} ${record.value}" : record.value
        ]
      }
    }
  }
}
