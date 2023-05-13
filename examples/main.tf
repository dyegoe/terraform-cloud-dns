locals {
  ttl  = 1
  name = "example.io"

  records = {
    root = { name = local.name, type = "A", value = "10.0.0.1" }
    api  = { name = "api", type = "A", value = "10.0.0.2", ttl = 1000 }
    new  = { name = "new.example.io", type = "CNAME", value = "api.example.io" }
    sub  = { name = "sub.domain", type = "CNAME", value = "new.example.io" }
    sub2 = { name = "sub2.domain.example.io", type = "CNAME", value = "new.example.io" }
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

module "all_records" {
  source = "../modules/records"

  name = local.name
  ttl  = local.ttl

  records = merge(
    module.mx_records_root.records,
    module.spf_records_root.records,
    module.skymail_records_root.records,
    local.records,
  )
}

output "records" {
  value = module.all_records.records
}
