# S3 Terraform Module

## Overview

This Terraform module creates a secure and configurable S3 bucket in AWS, with support for versioning, server-side encryption, lifecycle policies, CORS, and fine-grained access control.

## Example Usage

```hcl
module "s3_bucket" {
  source = "git@github.com:JustinJohnWilliams/infrastructure-modules-s3.git//module?ref=v1.0.0"

  bucket_name            = "my-awesome-s3-bucket"
  tags                   = { Environment = "Dev" }
  ip_whitelist           = ["192.168.1.1/32", "10.0.0.0/16"]
  encryption_type        = "aws:kms"
  lifecycle_configuration = {
    "expire_all_logs_in_30_days" = {
      status     = "Enabled"
      filter     = { prefix = "logs/" }
      expiration = { days = 30 }
    }
  }
  custom_policies = {
    "CustomPolicy1" = {
      Actions    = ["s3:GetObject"]
      Effect     = "Allow"
      Resources  = ["arn:aws:s3:::my-awesome-s3-bucket/*"]
      Principals = ["arn:aws:iam::123456789012:role/MyRole"]
    }
  }
  cors_rules = {
    "allow_web_app" = {
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  }
}
```
