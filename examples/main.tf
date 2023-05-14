locals {
  name = "example.io"
  ttl  = 1

  records = {
    root   = { name = local.name, type = "A", value = "10.0.0.1" }
    api    = { name = "api", type = "A", value = "10.0.0.2", ttl = 1000 }
    new    = { name = "new.example.io", type = "CNAME", value = "api.example.io" }
    sub    = { name = "sub.domain", type = "CNAME", value = "new.example.io" }
    sub2   = { name = "sub2.domain.example.io", type = "CNAME", value = "new.example.io" }
    alias2 = { name = "alias2", type = "A", value = "10.1.2.3" }
    alias3 = { name = "alias2", type = "A", value = "10.1.2.3" }
    alias4 = { name = "alias", type = "A", value = "10.1.2.3" }
    alias  = { name = "alias", type = "A", alias = { name = "example.io", zone_id = "1234567890", evaluate_target_health = true } }
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

  # records = merge(
  #   module.mx_records_root.records,
  #   module.spf_records_root.records,
  #   module.skymail_records_root.records,
  #   local.records,
  # )
  records = local.records
}

module "aws" {
  source = "../modules/aws"

  name = local.name
  ttl  = local.ttl

  records = module.all_records.records
}

output "records" {
  value = module.aws.records
}

output "records_aws" {
  value = module.aws.records_aws
}

output "validate_alias" {
  value = module.aws.validate_alias
}
