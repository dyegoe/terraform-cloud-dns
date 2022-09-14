output "zone_id" {
  value = aws_route53_zone.this[0].zone_id
}

output "name_servers" {
  value = aws_route53_zone.this[0].name_servers
}
