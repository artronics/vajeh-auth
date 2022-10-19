data "aws_route53_zone" "project_hosted_zone" {
  name = local.project_domain
}
