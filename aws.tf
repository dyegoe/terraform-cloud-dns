resource "aws_route53_zone" "this" {
  count = contains(var.cloud_providers, "aws") ? 1 : 0
  name  = var.name
}

resource "aws_route53_record" "mx_records" {
  for_each = flatten([
    for name, records in local.records["MX"] : [
      for record in records : {
        name  = name,
        type  = "MX",
        ttl   = record.ttl,
        value = "${record.priority} ${record.value}"
      }
    ]
  ])
  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
