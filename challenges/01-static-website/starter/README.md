# Starter — Challenge 01

This is your workspace. The challenge instructions are in `../README.md`.

## Quick start

```bash
cd starter/
terraform init
terraform apply
```

This will deploy a secure S3 bucket configured for static website hosting. But the site will return **AccessDenied** when you visit the URL. That's the challenge.

## What's already done for you

- Provider configuration (`providers.tf`)
- S3 bucket with a random suffix to keep the name globally unique
- Static website configuration on the bucket
- Versioning enabled (so deletes are recoverable)
- AES256 server-side encryption

## What you need to add to `main.tf`

1. An `aws_s3_object` resource that uploads `index.html` to your bucket
2. An `aws_s3_bucket_public_access_block` configured to allow public bucket policies
3. An `aws_s3_bucket_policy` that allows `s3:GetObject` for everyone (`Principal: "*"`)

## What you need to create

- `outputs.tf` — output the website URL so you can hit it from your terminal

## When you're done

```bash
terraform apply
curl $(terraform output -raw website_url)
```

You should see your HTML.

## Stuck?

Hints are in `../README.md`. Don't open `../solution/` until you've tried for at least 20 minutes.
