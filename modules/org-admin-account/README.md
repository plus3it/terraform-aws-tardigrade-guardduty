# terraform-aws-tardigrade-guardduty/organization_admin

Terraform module for managing a GuardDuty org_admin_account.
Creates a GuardDuty org administrator account in an AWS organization.  Once created, all AWS accounts added to the AWS organization will be enrolled in GuardDuty and managed by the delegated GuardDuty org administrator account
  - Creates a GuardDuty detector for the org's GuardDuty administrator account
  - Creates a GuardDuty organization administrator account
  - Configures the delegated GuardDuty administrator organization configuration

Prerequisites:  The AWS org must already exist

<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6 |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delegated_administrator_account_detecter_id"></a> [delegated\_administrator\_account\_detecter\_id](#input\_delegated\_administrator\_account\_detecter\_id) | (Required) GuardDuty detector ID of the AWS account identifier to designate as a delegated administrator for GuardDuty. | `string` | n/a | yes |
| <a name="input_delegated_administrator_account_id"></a> [delegated\_administrator\_account\_id](#input\_delegated\_administrator\_account\_id) | (Required) AWS account identifier to designate as a delegated administrator for GuardDuty. | `string` | n/a | yes |
| <a name="input_auto_enable_malware_protection"></a> [auto\_enable\_malware\_protection](#input\_auto\_enable\_malware\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_auto_enable_s3_protection"></a> [auto\_enable\_s3\_protection](#input\_auto\_enable\_s3\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | (Optional) Enable monitoring and feedback reporting. Setting to false is equivalent to 'suspending'GuardDuty. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_kubernetes_protection"></a> [enable\_kubernetes\_protection](#input\_enable\_kubernetes\_protection) | (Required) If true, enables S3 Protection. Defaults to true. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_organization_admin_account"></a> [organization\_admin\_account](#output\_organization\_admin\_account) | GuardDuty Organization Admin Account |

<!-- END TFDOCS -->
