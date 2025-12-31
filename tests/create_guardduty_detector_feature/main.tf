# Creates a GuardDuty Malware Protection for this account.
# - Creates a GuardDuty detector for this account.
# - Creates a GuardDuty detector feature for this account.

module "detector_features" {
  source = "../../"

  enable = true

  detector_features = [
    {
      name   = "EKS_RUNTIME_MONITORING"
      status = "ENABLED"
      region = data.aws_region.current.region
      additional_configuration = {
        name   = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    }
  ]
}

data "aws_region" "current" {}
