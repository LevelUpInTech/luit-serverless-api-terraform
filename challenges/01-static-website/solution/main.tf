# =============================================================================
# CHALLENGE 01 — REFERENCE SOLUTION
#
# Multiple ways to solve this. This is one clean, production-shaped version.
# Compare against your code — if yours is different but works, that's fine.
# =============================================================================

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "site" {
  bucket = "luit-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# Upload the HTML file
# -----------------------------------------------------------------------------
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

# -----------------------------------------------------------------------------
# Public access block: keep ACL blocking on (ACLs are the legacy bad-practice path),
# turn off the bucket-policy block so we can publish a scoped read policy below.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# -----------------------------------------------------------------------------
# Bucket policy granting read access to objects only.
# Note: depends_on the public access block — S3 rejects public policies if the
# block is still in place at policy-creation time.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "site_public_read" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.site]
}
