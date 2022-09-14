output "zone" {
  value = {
    aws = !contains(var.cloud_providers, "aws") ? null : {
      name         = aws_route53_zone.this[0].name
      id           = aws_route53_zone.this[0].zone_id
      name_servers = [for ns in aws_route53_zone.this[0].name_servers : ns]
      dnssec = !var.dnssec ? "" : {
        key_tag = aws_route53_key_signing_key.this[0].key_tag
        digest  = aws_route53_key_signing_key.this[0].digest_value
      }
    }
  }
}
