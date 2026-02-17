output "info" {
  value = {
    bucket = aws_s3_bucket.bucket
    policy = aws_s3_bucket_policy.bucket_policy
  }
}
