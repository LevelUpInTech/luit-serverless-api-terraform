terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # Remote state backend.
  # Run `cd bootstrap && terraform apply` once per AWS account before this works.
  # Then update the bucket/table names below to match the bootstrap outputs.
  backend "s3" {
    bucket         = "luit-tfstate-REPLACE-ME"
    key            = "luit-serverless-api/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "luit-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Repo        = "LevelUpInTech/luit-serverless-api-terraform"
    }
  }
}
