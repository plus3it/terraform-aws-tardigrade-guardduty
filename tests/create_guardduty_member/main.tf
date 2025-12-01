# The provider account for the GuardDuty member account
provider "aws" {
  region  = "us-east-1"
  profile = "aws" # Profile must exist in your .aws/config
}

# AWS provider account for the GuardDuty primary account
provider "aws" {
  region  = "us-east-1"
  alias   = "administrator"
  profile = "awsalternate" # Profile must exist in your .aws/config
}

# Create GuardDuty detector for the administrator account
resource "aws_guardduty_detector" "administrator" {
  provider = aws.administrator
  enable   = true
}

# Invite this member account to join the administrator account GuardDuty organization.
# - Creates a GuardDuty detector for the member account
# - Creates a GuardDuty member resource in the administrator account which imnvites the member account to join the administrator account GuardDuty organization.
# - Creates a GuardDuty invite accepter in the member account to accept the invite from the administrator account

module "guardduty" {
  source = "../../"

}

module "guardduty_member" {
  source = "../../modules/member"

  providers = {
    aws               = aws
    aws.administrator = aws.administrator
  }

  member = {
    account_id                 = module.guardduty.detector.account_id
    email                      = var.member_email
    invite                     = true
    invitation_message         = "You are invited to join GuardDuty"
    disable_email_notification = true
  }

  depends_on = [aws_guardduty_detector.administrator]
}

# Use a variable
variable "member_email" {
  description = "Email address associated with the member account. Required input for the Guardduty member invitation."
  type        = string
  default     = "john.doe@dummy.com"
}
