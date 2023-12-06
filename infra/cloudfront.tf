resource "aws_cloudfront_distribution" "blog_distribution" {
  origin {
    domain_name              = aws_s3_bucket.blog_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.blog_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.blog_origin_access_control.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.blog_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.path_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.blog_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = [join(".", [var.subdomain_name, var.domain_name])]

}

resource "aws_cloudfront_origin_access_control" "blog_origin_access_control" {
  name                              = "blog-origin-access-control"
  description                       = "Restrict access to my S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "path_rewrite" {
  name    = "path-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite path to index.html"
  publish = true
  code    = file("${path.module}/assets/function.js")
}