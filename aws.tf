resource "aws_route53_zone" "this" {
  count = contains(var.cloud_providers, "aws") ? 1 : 0
  name  = var.name
}

resource "aws_route53_record" "a_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["A"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.value
}

resource "aws_route53_record" "aaaa_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["AAAA"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.value
}

resource "aws_route53_record" "cname_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["CNAME"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.value
}

resource "aws_route53_record" "mx_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["MX"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.value
}

resource "aws_route53_record" "txt_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["TXT"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.value
}
