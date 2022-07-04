resource "aws_route53_zone" "api_pub_zone" {
  name                             = var.domain_name
}

resource "aws_acm_certificate" "api_pub_zone" {
  domain_name               = "example.${aws_route53_zone.api_pub_zone.name}"
  subject_alternative_names = [
    "example1.${aws_route53_zone.api_pub_zone.name}",
    "example2.${aws_route53_zone.api_pub_zone.name}",
    "example3.${aws_route53_zone.api_pub_zone.name}",
  ]
  validation_method         = "DNS"
}

resource "aws_route53_record" "example_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_pub_zone.domain_validation_options: dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.api_pub_zone.zone_id
}

resource "aws_acm_certificate_validation" "api_pub_zone" {
  certificate_arn         = aws_acm_certificate.api_pub_zone.arn
  validation_record_fqdns = [for record in aws_route53_record.example_validation: record.fqdn]
}