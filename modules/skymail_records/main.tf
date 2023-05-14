locals {
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
  records = {
    skymail_autodiscover = { name = "autodiscover.${var.name}", type = "CNAME", value = "autodiscover-ha.skymail.net.br" },
    skymail_imap         = { name = "imap.${var.name}", type = "CNAME", value = "imap-ha.skymail.net.br" },
    skymail_mail         = { name = "mail.${var.name}", type = "CNAME", value = "mail-ha.skymail.net.br" },
    skymail_pop          = { name = "pop.${var.name}", type = "CNAME", value = "pop-ha.skymail.net.br" },
    skymail_pop3         = { name = "pop3.${var.name}", type = "CNAME", value = "pop-ha.skymail.net.br" },
    skymail_smtp         = { name = "smtp.${var.name}", type = "CNAME", value = "smtp-ha.skymail.net.br" },
    skymail_owa          = { name = "owa.${var.name}", type = "CNAME", value = "webapp-ha.skymail.net.br" },
    skymail_webapp       = { name = "webapp.${var.name}", type = "CNAME", value = "webapp-ha.skymail.net.br" },
    skymail_webmail      = { name = "webmail.${var.name}", type = "CNAME", value = "webmail-ha.skymail.net.br" }
  }
}

output "records" {
  value = local.records
}
