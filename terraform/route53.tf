data "aws_route53_zone" "project_hosted_zone" {
  name = local.project_domain
}

resource "aws_acm_certificate" "auth_domain_certificate" {
  provider                  = aws.acm_provider
  domain_name               = local.auth_domain_name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cloud_front_hosted_zone_id = "Z2FDTNDATAQYW2" // It never changes
}

# AWS Cognito needs a root record that is reachable. We just use a dummy IP address
resource "aws_route53_record" "auth_root_domain_dummy" {
  zone_id = data.aws_route53_zone.project_hosted_zone.zone_id
  name    = local.root_auth_domain_name
  type    = "A"
  ttl     = 300
  records = ["127.0.0.1"]  # Placeholder that is never used. See: https://stackoverflow.com/a/56429359/3943054
}

#resource "aws_route53_record" "auth_domain_name" {
#  zone_id = data.aws_route53_zone.project_hosted_zone.zone_id
#  name    = aws_cognito_user_pool_domain.user_pool_domain_name.domain
#
#  type = "A"
#  alias {
#    evaluate_target_health = false
#    name                   = aws_cognito_user_pool_domain.user_pool_domain_name.cloudfront_distribution_arn
#    zone_id                = local.cloud_front_hosted_zone_id
#  }
#}

resource "aws_route53_record" "dns_validation" {
  for_each = {
  for dvo in aws_acm_certificate.auth_domain_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.project_hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation_root" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.auth_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
}
