resource "aws_s3_bucket" "blog_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloufront" {
  bucket = aws_s3_bucket.blog_bucket.id
  policy = templatefile("assets/s3-policy.tpl", {
    S3_BUCKET                  = aws_s3_bucket.blog_bucket.id
    ACCOUNT_ID                 = var.aws_account_id
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.blog_distribution.id
  })
}
