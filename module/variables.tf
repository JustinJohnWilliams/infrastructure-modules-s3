# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "bucket_name" {
  description = "Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found [here](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html). The name must not be in the format `[bucket_name]--[azid]--x-s3`"
  type        = string
  default     = null
}

variable "bucket_acl" {
  description = "Canned ACL type. Should be one of the following `private`, `public-read`, `public-read-write`, or `log-delivery-write`"
  type        = string
  default     = "private"
}

variable "bucket_ownership" {
  description = "Ownership of the items written to the bucket"
  type        = string
  default     = "ObjectWriter"
  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.bucket_ownership)
    error_message = "Object ownership. Must be one of `BucketOwnerPreferred`, `ObjectWriter`, or `BucketOwnerEnforced`."
  }
}

variable "enabled_versioning" {
  description = "True or False to control the versioning of the bucket"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "When set to true, this option prevents the bucket and its objects from having any public ACLs assigned."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "When set to true, this option ensures that the bucket cannot have a public bucket policy."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "When set to true, this option ignores any public ACLs that are already assigned to the bucket or its objects."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "When set to true, this option restricts the bucket so that only AWS account owners and AWS services can access the bucket if it has a public policy."
  type        = bool
  default     = true
}

variable "ip_whitelist" {
  description = "Adds a bucket policy that only allows the IPs in the whitelist"
  type        = list(string)
  default     = []
}

variable "enable_tls_policy" {
  description = "Whether or not to add the EnforcedTLS Policy block"
  type        = bool
  default     = true
}

variable "enable_root_access_policy" {
  description = "Whether or not to add the RootAccess Policy block"
  type        = bool
  default     = true
}

variable "bucket_policy" {
  description = "JSON document of the bucket policy. Use this parameter or pass in `custom_policies`"
  type        = string
  default     = ""
}

variable "custom_policies" {
  description = "map of custom policies to apply to the bucket"
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
    Principal = optional(object({
      Type        = string,
      Identifiers = list(string)
    }))
    NotPrincipal = optional(object({
      Type        = string,
      Identifiers = list(string)
    }))
    Condition = optional(object({
      Test     = string,
      Variable = string,
      Values   = list(string)
    }))
  }))
  default = {}
}

variable "encryption_type" {
  description = "type of server side encryption, defaults to aws:kms"
  type        = string
  default     = "aws:kms"
  validation {
    condition     = var.encryption_type == "AES256" || var.encryption_type == "aws:kms"
    error_message = "The encryption type must be either AES256 or aws:kms"
  }
}

variable "lifecycle_configuration" {
  description = "Map of lifecycle configurations to apply to the bucket"
  type = map(object({
    # (Required) Lifecycle rule status: \"Enabled\" or \"Disabled\"
    status = string

    # (Optional) Filter identifying objects to which the rule applies.
    # Example: { prefix = "SomeFolder/" }
    filter = optional(object({
      prefix = string
    }))

    # (Optional) Current object expiration
    # Example: { days = 14 }
    expiration = optional(object({
      days = number
    }))

    # (Optional) Noncurrent version expiration (for versioned buckets)
    # Example: { noncurrent_days = 14 }
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number)
    }))

    # (Optional) Abort incomplete multipart uploads
    # Example: { days_after_initiation = 7 }
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default = {}
}

variable "object_lock_configuration" {
  description = "Object Lock default retention configuration for the bucket. Enables Object Lock when provided."
  type = object({
    # Object Lock retention mode: GOVERNANCE or COMPLIANCE
    mode = string
    # Retention period - specify either days or years, not both
    days  = optional(number)
    years = optional(number)
  })
  default  = null
  nullable = true
}

variable "cors_rules" {
  description = "Map of CORS rules to apply to the bucket"
  type = map(object({
    allowed_methods = list(string)           # (Required) e.g. ["GET", "PUT", "POST"]
    allowed_origins = list(string)           # (Required) e.g. ["https://example.com"]
    allowed_headers = optional(list(string)) # (Optional) e.g. ["*"]
    expose_headers  = optional(list(string)) # (Optional) e.g. ["ETag"]
    max_age_seconds = optional(number)       # (Optional) e.g. 3000
  }))
  default = {}
}

variable "enable_eventbridge" {
  description = "Enable EventBridge notifications for this bucket"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(any)
  default = {}
}
