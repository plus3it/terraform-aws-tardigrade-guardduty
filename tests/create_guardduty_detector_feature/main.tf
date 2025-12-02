# Creates a GuardDuty Malware Protection for this account.
# - Creates a GuardDuty detector for this account.
# - Creates a GuardDuty detector feature for this account.

module "detector_features" {
  source = "../../"

  enable = true

  detector_features = [
    {
      name   = "LAMBDA_NETWORK_LOGS"
      status = "ENABLED"
      region = data.aws_region.current.name
      additional_configuration = {
        name   = "EC2_AGENT_MANAGEMENT"
        status = "ENABLED"
      }
    }
  ]
}

data "aws_region" "current" {}
