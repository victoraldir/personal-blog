output "bucket_name" {
  value       = aws_s3_bucket.blog_bucket.id
  description = "Bucket id that stores the blog content"
}

output "distribution_id" {
  value       = aws_cloudfront_distribution.blog_distribution.id
  description = "Cloudfront distribution id"
}
