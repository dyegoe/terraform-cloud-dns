locals {
  name = "example.io"
  ttl  = 1

  records = [
    { name = "@", type = "A", value = "10.0.0.1" },
    { name = "api", type = "A", value = "10.0.0.2", ttl = 1000 },
    { name = "new.example.io", type = "CNAME", value = "ap.example.io" },
    { name = "sub.domain", type = "CNAME", value = "new.example.io" },
    { name = "sub2.domain.example.io", type = "CNAME", value = "new.example.io" },
    { name = "alias2", type = "A", value = "10.1.2.3" },
    { name = "alias2", type = "A", value = "10.1.2.2" },
    { name = "alias1", type = "A", value = "10.1.2.1" },
    { name = "alias", type = "A", alias = { name = "example.io", zone_id = "1234567890", evaluate_target_health = true } },
  ]
}

provider "aws" {
  region  = "eu-north-1"
  profile = "default"
}

module "records" {
  source = "../modules/records"

  name = local.name
  ttl  = local.ttl

  records = local.records
}

module "aws" {
  source = "../modules/aws"

  name = local.name
  ttl  = local.ttl

  records = local.records
}
