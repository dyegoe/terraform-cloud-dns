module "cloud_dns" {
  source = "../"

  ttl = 1

  spf_providers_list = ["google", "mcsv", "skymail", "sendgrid"]
  mx_providers_list  = ["google", "skymail"]
}

output "mx_records" {
  value = module.cloud_dns.mx_records
}

output "spf_records" {
  value = module.cloud_dns.spf_records
}
