resource "aws_route53domains_registered_domain" "blog_domain" {
  domain_name = var.domain_name
}

data "aws_route53_zone" "blog_zone" {
  name = aws_route53domains_registered_domain.blog_domain.domain_name
}

resource "aws_route53_record" "blog_record" {
  zone_id = data.aws_route53_zone.blog_zone.zone_id
  name    = join(".", [var.subdomain_name, var.domain_name])
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.blog_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.blog_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
