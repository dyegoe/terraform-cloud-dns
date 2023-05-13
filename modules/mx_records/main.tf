locals {
  // ... Record fields
  // name     = string
  // type     = string
  // value    = string
  // ttl      = optional(number)
  // priority = optional(string)
  // proxied  = optional(bool)
  mx_providers = {
    google = {
      mx_google_1 = { name = var.name, type = "MX", value = "aspmx.l.google.com", ttl = var.ttl, priority = "1" },
      mx_google_2 = { name = var.name, type = "MX", value = "alt1.aspmx.l.google.com", ttl = var.ttl, priority = "5" },
      mx_google_3 = { name = var.name, type = "MX", value = "alt2.aspmx.l.google.com", ttl = var.ttl, priority = "5" },
      mx_google_4 = { name = var.name, type = "MX", value = "alt3.aspmx.l.google.com", ttl = var.ttl, priority = "10" },
      mx_google_5 = { name = var.name, type = "MX", value = "alt4.aspmx.l.google.com", ttl = var.ttl, priority = "10" },
    },
    skymail = {
      mx_skymail_1 = { name = var.name, type = "MX", value = "mx-ha.skymail.net.br", ttl = var.ttl, priority = "1" }
    }
  }
}

output "records" {
  value = local.mx_providers[var.mx_provider]
}
