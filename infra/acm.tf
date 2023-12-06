resource "aws_acm_certificate" "blog_certificate" {
  domain_name       = join(".", [var.subdomain_name, var.domain_name])
  validation_method = "DNS"

  provider = aws.us
}

resource "aws_route53_record" "blog_certificate_validation" {
  count = length(aws_acm_certificate.blog_certificate.domain_validation_options)

  name    = element(aws_acm_certificate.blog_certificate.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.blog_certificate.domain_validation_options.*.resource_record_type, count.index)
  zone_id = data.aws_route53_zone.blog_zone.zone_id
  records = [element(aws_acm_certificate.blog_certificate.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "blog_certificate_validation" {
  certificate_arn         = aws_acm_certificate.blog_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.blog_certificate_validation : record.fqdn]

  provider = aws.us
}
