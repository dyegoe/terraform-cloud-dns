locals {
  ttl  = 1
  name = "example.io"

  records = {
    api  = { name = "api", type = "A", value = "10.0.0.2", ttl = 1 }                 # true
    mx1  = { name = "mx1", type = "MX", value = "aspmx.l.google.com", priority = 1 } # true
    mx2  = { name = "mx2", type = "A", value = "aspmx.l.google.com", priority = 1 }  # false
    mx3  = { name = "mx3", type = "MX", value = "aspmx.l.google.com" }               # false
    root = { name = "root", type = "A", value = "10.0.0.1" }                         # true
  }
}

module "mx_records_root" {
  source = "../modules/mx_records"

  name = local.name
  ttl  = local.ttl

  mx_provider = "google"
}

module "spf_records_root" {
  source = "../modules/spf_records"

  name = local.name
  ttl  = local.ttl

  spf_providers_list = ["google", "mcsv", "skymail", "sendgrid"]
}

module "skymail_records_root" {
  source = "../modules/skymail_records"

  name = local.name
  ttl  = local.ttl
}

# module "cloud_dns" {
#   source = "../"

#   name = local.name
#   ttl  = local.ttl

#   records = {
#     root = { name = "@", type = "A", value = "10.0.0.1" }
#     api  = { name = "api", type = "A", value = "10.0.0.2", ttl = 1 }
#     mx1  = { name = "@", type = "MX", value = "aspmx.l.google.com", priority = 1 }
#   }
# }

output "records" {
  value = merge(
    module.mx_records_root.records,
    module.spf_records_root.records,
    module.skymail_records_root.records,
    {
      root = { name = "@", type = "A", value = "10.0.0.1" }
      api  = { name = "api", type = "A", value = "10.0.0.2", ttl = 1 }
      mx1  = { name = "@", type = "MX", value = "aspmx.l.google.com", priority = 1 }
    }
  )
}

output "test" {
  value = {
    for record in local.records : record.name => record.type == "MX" if try(record.priority, null) != null
  }
}
