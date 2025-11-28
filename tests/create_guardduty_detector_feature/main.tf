# Creates a GuardDuty Malware Protection for this account.
# - Creates a GuardDuty detector for this account
# - Creates a GuardDuty Malware Protection for this account
# - Creates IAM Role for GuardDuty Malware Protection for this account.
# - Creates IAM Policy and Attachment for GuardDuty Malware Protection for this account.
# - Creates S3 Bucket for GuardDuty Malware Protection for this account.

module "malware_protection_plan" {
  source = "../../"

  enable = true

  detector_feature = {
    name   = "LAMBDA_NETWORK_LOGS"
    status = "ENABLED"
    region = data.aws_region.current.name
    additional_configuration = {
      name   = "EC2_AGENT_MANAGEMENT"
      status = "ENABLED"
    }
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
