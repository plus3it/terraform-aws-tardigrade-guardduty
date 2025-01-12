# terraform-aws-tardigrade-guardduty

Terraform module to create a standard GuardDuty configuration in a single AWS account.  These include a GuardDuty detector, filter, ipset, threatintelset, and publshing destination.  GuardDuty configurations that require multiple AWS accounts are not included in this module, and the terraform code for those configurations has been implemented in seperate submodeles (see the modules section of this project).

  - Creates a GuardDuty detector for this account
  - Creates zero or more GuardDuty filters for this account if the filter var is not null.
  - Creates zero or more GuardDuty ipsets for this account if the ipset var is not null.
  - Creates zero or more GuardDuty threatintelsets for this account if the threatintelset var is not null.
  - Creates a GuardDuty publishing_destination for this account if the publishing_destination var is not null.

Prerequisites:  This publishing_destination resource assumes the S3 bucket associated with the destination arn exists and the required policies have been created to
allow GuardDuty to access the bucket.  It also assumes the kms key associated with the kms key arn exists and has a policy that allows GuardDuty to to use it.

## Testing

You can find example implementations of this module in the tests folder (create_all_guardduty_standard_resources). 


<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.24.0 |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Enable GuardDuty monitoring and feedback reporting. Setting to false is equivalent to 'suspending'GuardDuty. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_kubernetes_protection"></a> [enable\_kubernetes\_protection](#input\_enable\_kubernetes\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_malware_protection"></a> [enable\_malware\_protection](#input\_enable\_malware\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_s3_protection"></a> [enable\_s3\_protection](#input\_enable\_s3\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_filters"></a> [filters](#input\_filters) | GuardDuty filter configuration list | <pre>list(object({<br/>    name        = string                   # (Required) The name of your filter.  SPACES ARE NOT ALOWED<br/>    description = string                   # (Optional) Description of the filter.<br/>    rank        = number                   # (Required) Specifies the position of the filter in the list of current filters. Also specifies the order in which this filter is applied to the findings.<br/>    action      = string                   # (Required) Specifies the action that is to be applied to the findings that match the filter. Can be one of ARCHIVE or NOOP.<br/>    tags        = map(string)              # (Optional) - The tags that you want to add to the Filter resource. A tag consists of a key and a value.<br/>    criterion = list(object({              # (Represents the criteria to be used in the filter for querying findings. Contains one or more criterion blocks<br/>      field                 = string       # (Required) The name of the field to be evaluated. The full list of field names can be found in AWS documentation.<br/>      equals                = list(string) # (Optional) List of string values to be evaluated.<br/>      not_equals            = list(string) # (Optional) List of string values to be evaluated.<br/>      greater_than          = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.<br/>      greater_than_or_equal = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.<br/>      less_than             = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.<br/>      less_than_or_equal    = string       # (Optional) A value to be evaluated. Accepts either an integer or a date in RFC 3339 format.<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | (Optional) Specifies the frequency of notifications sent for subsequent finding occurrences. If the detector is a GuardDuty member account, the value is determined by the GuardDuty primary account and cannot be modified, otherwise defaults to SIX\_HOURS. For standalone and GuardDuty primary accounts, it must be configured in Terraform to enable drift detection. Valid values for standalone and primary accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS. | `string` | `"SIX_HOURS"` | no |
| <a name="input_ipsets"></a> [ipsets](#input\_ipsets) | GuardDuty ipset list | <pre>list(object({<br/>    activate = bool        # (Required) Specifies whether GuardDuty is to start using the uploaded IPSet.<br/>    format   = string      # (Required) The format of the file that contains the IPSet. Valid values: TXT | STIX | OTX_CSV | ALIEN_VAULT | PROOF_POINT | FIRE_EYE<br/>    location = string      # (Required) The URI of the file that contains the IPSet.<br/>    name     = string      # (Required) The friendly name to identify the IPSet.<br/>    tags     = map(string) # (Optional) Key-value map of resource tags.<br/>  }))</pre> | `[]` | no |
| <a name="input_publishing_destination"></a> [publishing\_destination](#input\_publishing\_destination) | GuardDuty publishing destination | <pre>object({<br/>    destination_arn  = string # (Required) The bucket arn and prefix under which the findings get exported. Bucket-ARN is required, the prefix is optional and will be AWSLogs/[Account-ID]/GuardDuty/[Region]/ if not provided<br/>    kms_key_arn      = string # (Required) The ARN of the KMS key used to encrypt GuardDuty findings. GuardDuty enforces this to be encrypted.<br/>    destination_type = string # (Optional) Currently there is only "S3" available as destination type which is also the default value<br/>  })</pre> | `null` | no |
| <a name="input_threatintelsets"></a> [threatintelsets](#input\_threatintelsets) | GuardDuty threatintelset list | <pre>list(object({<br/>    activate = bool        # (Required) Specifies whether GuardDuty is to start using the uploaded threatintelset.<br/>    format   = string      # (Required) The format of the file that contains the threatintelset. Valid values: TXT | STIX | OTX_CSV | ALIEN_VAULT | PROOF_POINT | FIRE_EYE<br/>    location = string      # (Required) The URI of the file that contains the threatintelset.<br/>    name     = string      # (Required) The friendly name to identify the threatintelset.<br/>    tags     = map(string) # (Optional) Key-value map of resource tags.<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_detector"></a> [detector](#output\_detector) | GuardDuty detector |
| <a name="output_filter"></a> [filter](#output\_filter) | GuardDuty filter |
| <a name="output_ipset"></a> [ipset](#output\_ipset) | GuardDuty ipset |
| <a name="output_publishing_destination"></a> [publishing\_destination](#output\_publishing\_destination) | GuardDuty publishing destination |
| <a name="output_threatintelset"></a> [threatintelset](#output\_threatintelset) | GuardDuty threatintelset |

<!-- END TFDOCS -->
