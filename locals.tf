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
        name = "@", type = "MX", ttl = var.ttl_default, priority = record.priority, value = record.value
      }
    ]
  ])

  // A root --------------------------------------------------------------------
  a_root = var.a_root != "" ? [
    { name = "@", type = "A", ttl = var.ttl_default, value = var.a_root, alias = var.a_root_type == "ALIAS" ? true : null, zone_id = var.a_root_type == "ALIAS" ? var.a_root_zone_id : null }
  ] : []

  // CNAME www to root ---------------------------------------------------------
  cname_www_root = var.cname_www_root ? [
    { name = "www", type = "CNAME", ttl = var.ttl_default, value = "@" }
  ] : []

  // CNAME mail related to skymail ---------------------------------------------
  cname_mail_skymail = var.cname_mail_skymail ? [
    { name = "autodiscover", type = "CNAME", value = "autodiscover-ha.skymail.net.br" },
    { name = "imap", type = "CNAME", value = "imap-ha.skymail.net.br" },
    { name = "mail", type = "CNAME", value = "mail-ha.skymail.net.br" },
    { name = "pop", type = "CNAME", value = "pop-ha.skymail.net.br" },
    { name = "pop3", type = "CNAME", value = "pop-ha.skymail.net.br" },
    { name = "smtp", type = "CNAME", value = "smtp-ha.skymail.net.br" },
    { name = "owa", type = "CNAME", value = "webapp-ha.skymail.net.br" },
    { name = "webapp", type = "CNAME", value = "webapp-ha.skymail.net.br" },
    { name = "webmail", type = "CNAME", value = "webmail-ha.skymail.net.br" }
  ] : []

  // Records -------------------------------------------------------------------
  records_merge = concat(var.records, local.mx_records, local.spf, local.a_root, local.cname_www_root, local.cname_mail_skymail)
  # { name = "@", type = "TXT", ttl = "300", priority = null, value = "value" },
  records_tmp = {
    for record in local.records_merge : record.type => {
      name     = record.name == "@" ? var.name : record.name
      ttl      = try(record.ttl, var.ttl_default)
      priority = try(record.priority, null)
      value    = record.value == "@" ? var.name : record.value
      alias    = try(record.alias, null)
      zone_id  = try(record.zone_id, null)
    }...
  }
  records = {
    for type, records in local.records_tmp : type => {
      for record in records : record.name => {
        value    = record.value
        ttl      = record.ttl
        priority = record.priority
        alias    = record.alias
        zone_id  = record.zone_id
      }...
    }
  }
  records_aws = {
    for type, names in local.records : type => {
      for name, records in names : name => {
        name    = name,
        type    = type,
        ttl     = element(sort([for record in records : record.ttl]), 0),
        alias   = try(records[0].alias, null),
        zone_id = try(records[0].zone_id, null),
        value = [
          for record in records : type == "MX" ? "${record.priority} ${record.value}" : record.value
        ]
      }
    }
  }
}
