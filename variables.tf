variable "enable" {
  description = "(Optional) Enable GuardDuty monitoring and feedback reporting. Setting to false is equivalent to 'suspending'GuardDuty. Defaults to true."
  type        = bool
  default     = true
}

variable "enable_s3_protection" {
  description = "(Required) If true, enables S3 Protection. Defaults to true."
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "(Required) If true, enables S3 Protection. Defaults to true."
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "(Required) If true, enables S3 Protection. Defaults to true."
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "(Optional) Specifies the frequency of notifications sent for subsequent finding occurrences. If the detector is a GuardDuty member account, the value is determined by the GuardDuty primary account and cannot be modified, otherwise defaults to SIX_HOURS. For standalone and GuardDuty primary accounts, it must be configured in Terraform to enable drift detection. Valid values for standalone and primary accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"
  validation {
    condition     = var.finding_publishing_frequency != null ? contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency) : true
    error_message = "The aws_guardduty_detector finding_publishing_frequency value is not valid. Valid values: FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "filters" {
  description = "GuardDuty filter configuration list"
  type = list(object({
    name        = string                   # (Required) The name of your filter.  SPACES ARE NOT ALOWED
    description = string                   # (Optional) Description of the filter.
    rank        = number                   # (Required) Specifies the position of the filter in the list of current filters. Also specifies the order in which this filter is applied to the findings.
    action      = string                   # (Required) Specifies the action that is to be applied to the findings that match the filter. Can be one of ARCHIVE or NOOP.
    tags        = map(string)              # (Optional) - The tags that you want to add to the Filter resource. A tag consists of a key and a value.
    criterion = list(object({              # (Represents the criteria to be used in the filter for querying findings. Contains one or more criterion blocks
      field                 = string       # (Required) The name of the field to be evaluated. The full list of field names can be found in AWS documentation.
      equals                = list(string) # (Optional) List of string values to be evaluated.
      not_equals            = list(string) # (Optional) List of string values to be evaluated.
      greater_than          = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.
      greater_than_or_equal = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.
      less_than             = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.
      less_than_or_equal    = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.
    }))
  }))
  default = []
}

variable "ipsets" {
  description = "GuardDuty ipset list"
  type = list(object({
    activate = bool        # (Required) Specifies whether GuardDuty is to start using the uploaded IPSet.
    format   = string      # (Required) The format of the file that contains the IPSet. Valid values: TXT | STIX | OTX_CSV | ALIEN_VAULT | PROOF_POINT | FIRE_EYE
    location = string      # (Required) The URI of the file that contains the IPSet.
    name     = string      # (Required) The friendly name to identify the IPSet.
    tags     = map(string) # (Optional) Key-value map of resource tags.
  }))
  default = []
}

variable "threatintelsets" {
  description = "GuardDuty threatintelset list"
  type = list(object({
    activate = bool        # (Required) Specifies whether GuardDuty is to start using the uploaded threatintelset.
    format   = string      # (Required) The format of the file that contains the threatintelset. Valid values: TXT | STIX | OTX_CSV | ALIEN_VAULT | PROOF_POINT | FIRE_EYE
    location = string      # (Required) The URI of the file that contains the threatintelset.
    name     = string      # (Required) The friendly name to identify the threatintelset.
    tags     = map(string) # (Optional) Key-value map of resource tags.
  }))
  default = []
}

variable "protection_plans" {
  description = "Provides a resource to manage a GuardDuty malware protection plan."
  type = map(object({
    role   = string
    region = optional(string)
    tags   = optional(map(string))

    actions = optional(object({
      tagging = object({
        status = string
      })
    }))

    protected_resource = object({
      s3_bucket = object({
        bucket_name     = string
        object_prefixes = optional(list(string))
      })
    })
  }))
  default = null
}

variable "publishing_destination" {
  description = "GuardDuty publishing destination"
  type = object({
    destination_arn  = string # (Required) The bucket arn and prefix under which the findings get exported. Bucket-ARN is required, the prefix is optional and will be AWSLogs/[Account-ID]/GuardDuty/[Region]/ if not provided
    kms_key_arn      = string # (Required) The ARN of the KMS key used to encrypt GuardDuty findings. GuardDuty enforces this to be encrypted.
    destination_type = string # (Optional) Currently there is only "S3" available as destination type which is also the default value
  })
  default = null
}
