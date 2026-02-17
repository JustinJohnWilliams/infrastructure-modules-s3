data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_caller_identity" "account" {
}

data "aws_iam_policy_document" "doc" {
  dynamic "statement" {
    for_each = var.enable_tls_policy ? ["tls"] : []
    content {
      sid     = "EnforcedTLS"
      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*",
      ]
      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
      principals {
        identifiers = ["*"]
        type        = "*"
      }
    }
  }
  dynamic "statement" {
    for_each = var.enable_root_access_policy ? ["rootaccess"] : []
    content {
      sid     = "RootAccess"
      effect  = "Allow"
      actions = ["s3:*"]
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"]
      }
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*",
      ]
    }
  }
  dynamic "statement" {
    for_each = length(var.ip_whitelist) > 0 ? ["apply"] : []
    content {
      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*",
      ]
      condition {
        test     = "NotIpAddress"
        variable = "aws:SourceIp"
        values   = var.ip_whitelist
      }
    }
  }
  dynamic "statement" {
    for_each = var.custom_policies

    content {
      sid       = statement.key
      actions   = statement.value.Actions
      resources = statement.value.Resources
      effect    = statement.value.Effect
      dynamic "principals" {
        for_each = lookup(statement.value, "Principal", null) != null ? [statement.value.Principal] : []
        content {
          type        = principals.value.Type
          identifiers = principals.value.Identifiers
        }
      }
      dynamic "not_principals" {
        for_each = lookup(statement.value, "NotPrincipal", null) != null ? [statement.value.NotPrincipal] : []
        content {
          type        = not_principals.value.Type
          identifiers = not_principals.value.Identifiers
        }
      }
      dynamic "condition" {
        for_each = lookup(statement.value, "Condition", null) != null ? [statement.value.Condition] : []
        content {
          test     = condition.value.Test
          variable = condition.value.Variable
          values   = condition.value.Values
        }
      }
    }
  }
}
