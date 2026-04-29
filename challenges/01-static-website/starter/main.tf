# =============================================================================
# CHALLENGE 01 — STARTER
#
# This file is INCOMPLETE on purpose. Your job is to add three things:
#   1. An aws_s3_object resource to upload index.html
#   2. An aws_s3_bucket_public_access_block that allows public bucket policies
#   3. An aws_s3_bucket_policy that grants s3:GetObject to everyone
#
# Search for "TODO" below for hints on where to add things.
# =============================================================================

# Globally unique suffix so your bucket name doesn't collide with someone else's
resource "random_id" "suffix" {
  byte_length = 4
}

# The bucket itself
resource "aws_s3_bucket" "site" {
  bucket = "luit-${random_id.suffix.hex}"
}

# Turn the bucket into a website host
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# Versioning: deleted files can be recovered
resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption at rest — required by most security audits
resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# TODO 1: Upload index.html to the bucket
#
# Hint: the resource type starts with "aws_s3_object". You'll need the bucket
# name, a key (the path inside the bucket), the local source file, and a
# content_type.
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# TODO 2: Configure the public access block
#
# Hint: by default, S3 blocks ALL forms of public access on new buckets.
# You need to KEEP block_public_acls = true (ACLs are the bad way to do this)
# but allow public bucket policies. The resource is aws_s3_bucket_public_access_block.
# Read https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
# to see all four flags and figure out which to keep on and which to turn off.
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# TODO 3: Add a bucket policy allowing public reads
#
# Hint: aws_s3_bucket_policy with a JSON policy document. Action is
# s3:GetObject, Effect is Allow, Principal is "*", Resource is the bucket
# ARN with /* on the end (so it applies to objects, not the bucket itself).
#
# IMPORTANT: this policy must be created AFTER the public access block,
# otherwise S3 will reject it. Use depends_on if you need to.
# -----------------------------------------------------------------------------
