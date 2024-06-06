data "aws_caller_identity" "this" {
  count = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
}

data "aws_iam_policy_document" "this" {
  count = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
  statement {
    actions = ["kms:DescribeKey", "kms:GetPublicKey", "kms:Sign"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["${data.aws_caller_identity.this[0].account_id}"]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:route53:::hostedzone/*"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    actions = ["kms:CreateGrant"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "Bool"
      values   = ["true"]
      variable = "kms:GrantIsForAWSResource"
    }
  }

  statement {
    actions = ["kms:*"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this[0].account_id}:root"]
    }
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.aws_kms_users_arn) > 0 ? [1] : []
    content {
      actions = ["kms:*"]
      effect  = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.aws_kms_users_arn
      }
      resources = ["*"]
    }
  }
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
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_kms_alias" "this" {
  count         = contains(var.cloud_providers, "aws") && var.dnssec ? 1 : 0
  name          = "alias/${replace(var.name, ".", "-")}"
  target_key_id = aws_kms_key.this[0].key_id
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
