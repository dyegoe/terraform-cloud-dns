data "aws_caller_identity" "this" {
  count = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
}

resource "aws_kms_key" "this" {
  count                    = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
  description              = "DNSSEC: ${var.name}"
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  tags = {
    Name   = var.name
    dnssec = "true"
  }
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service",
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.this[0].account_id}"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Action = "kms:CreateGrant",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service to CreateGrant",
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this[0].account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_route53_zone" "this" {
  count = contains(var.cloud_providers, "aws") ? 1 : 0
  name  = var.name
}

resource "aws_route53_key_signing_key" "this" {
  count                      = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
  hosted_zone_id             = aws_route53_zone.this[0].id
  key_management_service_arn = aws_kms_key.this[0].arn
  name                       = var.name
}

resource "aws_route53_hosted_zone_dnssec" "this" {
  count          = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
  depends_on     = [aws_route53_key_signing_key.this]
  hosted_zone_id = aws_route53_key_signing_key.this[0].hosted_zone_id
}

resource "aws_route53_record" "a_records" {
  for_each = contains(var.cloud_providers, "aws") ? try(local.records_aws["A"], {}) : {}
  zone_id  = aws_route53_zone.this[0].zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.alias ? null : each.value.ttl
  records  = each.value.alias ? null : each.value.value
  dynamic "alias" {
    for_each = each.value.alias ? [1] : []
    content {
      name                   = each.value.value[0]
      zone_id                = each.value.zone_id
      evaluate_target_health = false
    }
  }
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
