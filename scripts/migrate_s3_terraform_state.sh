#!/bin/bash

# Function to migrate Terraform state
migrate_s3_terraform_state() {
    local commands=(
    "terragrunt state mv 'aws_s3_bucket.bucket' 'module.s3_bucket.aws_s3_bucket.bucket'"
    "terragrunt state mv 'aws_s3_bucket_acl.bucket_acl' 'module.s3_bucket.aws_s3_bucket_acl.bucket_acl'"
    "terragrunt state mv 'aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership' 'module.s3_bucket.aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership'"
    "terragrunt state mv 'aws_s3_bucket_policy.bucket_policy' 'module.s3_bucket.aws_s3_bucket_policy.bucket_policy'"
    "terragrunt state mv 'aws_s3_bucket_public_access_block.public_access_block' 'module.s3_bucket.aws_s3_bucket_public_access_block.public_access_block'"
    "terragrunt state mv 'aws_s3_bucket_server_side_encryption_configuration.bucket_sse' 'module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.bucket_sse'"
    "terragrunt state mv 'aws_s3_bucket_versioning.bucket_versioning' 'module.s3_bucket.aws_s3_bucket_versioning.bucket_versioning'"
  )

  for cmd in "${commands[@]}"; do
    echo "Executing: $cmd"
    eval "$cmd"
    if [ $? -ne 0 ]; then
      echo "Command failed: $cmd"
      return 1
    fi
  done

  echo "All commands executed successfully."
  return 0
}

