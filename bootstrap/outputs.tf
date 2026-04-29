output "tfstate_bucket" {
  description = "Name of the S3 bucket holding Terraform remote state. Paste this into providers.tf."
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table" {
  description = "Name of the DynamoDB table holding state locks."
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "next_steps" {
  description = "Copy these values into the backend block in ../providers.tf."
  value       = <<EOT

  Bootstrap complete. Update ../providers.tf:

  terraform {
    backend "s3" {
      bucket         = "${aws_s3_bucket.tfstate.bucket}"
      key            = "luit-serverless-api/terraform.tfstate"
      region         = "${var.aws_region}"
      dynamodb_table = "${aws_dynamodb_table.tfstate_lock.name}"
      encrypt        = true
    }
  }

  Then: cd .. && terraform init && terraform apply

EOT
}
