# Creates a GuardDuty Malware Protection for this account.
# - Creates a GuardDuty detector for this account.
# - Creates a GuardDuty detector feature for this account.

module "detector_features" {
  source = "../../"

  enable = true

  detector_features = {
    RDS_LOGIN_EVENTS = {
      status = "ENABLED"
      additional_configuration = {
        RDS_DATA_RISK = {
          status = "DISABLED"
        }
      }
    }
    RUNTIME_MONITORING = {
      exclude = false
      status  = "ENABLED"
      region  = data.aws_region.current.region
      additional_configuration = {
        EKS_ADDON_MANAGEMENT = {
          status = "ENABLED"
        }
        ECS_FARGATE_AGENT_MANAGEMENT = {
          status = "ENABLED"
        }
        EC2_AGENT_MANAGEMENT = {
          status = "ENABLED"
        }
      }
    }
  }
}

data "aws_region" "current" {}
