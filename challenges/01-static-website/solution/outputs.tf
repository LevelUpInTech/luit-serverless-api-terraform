output "website_url" {
  description = "Public URL of the static website. Visit this in a browser to confirm the site is live."
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the S3 bucket hosting the site."
  value       = aws_s3_bucket.site.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket. Useful when wiring this bucket to other AWS services."
  value       = aws_s3_bucket.site.arn
}
