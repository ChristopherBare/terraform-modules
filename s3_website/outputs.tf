# outputs.tf

output "website_url" {
  description = "URL for accessing the website"
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}
