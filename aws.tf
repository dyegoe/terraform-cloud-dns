resource "aws_route53_zone" "this" {
  count = contains(var.cloud_providers, "aws") ? 1 : 0
  name  = var.name
}
