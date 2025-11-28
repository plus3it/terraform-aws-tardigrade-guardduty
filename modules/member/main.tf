# Invites a member account to join an administrator account GuardDuty organization.
# - Creates a GuardDuty detector for the member account
# - Creates a GuardDuty member resource in the administrator account which imnvites the member account to join the administrator account GuardDuty organization.
# - Creates a GuardDuty invite accepter in the member account to accept the invite from the administrator account
#
# Prerequisites:  The administrator account GuardDuty detector must already be enabled

# Create GuardDuty detector for the member account
resource "aws_guardduty_detector" "this" {
  enable = var.enable

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_protection
      }
    }

    dynamic "malware_protection" {
      for_each = var.enable_malware_protection != null ? ["one"] : []

      content {
        scan_ec2_instance_with_findings {
          ebs_volumes {
            enable = var.enable_malware_protection
          }
        }
      }
    }
  }
}

# Create GuardDuty member in the administrator account
resource "aws_guardduty_member" "this" {
  provider = aws.administrator

  account_id                 = aws_guardduty_detector.this.account_id
  detector_id                = data.aws_guardduty_detector.administrator.id
  email                      = var.member.email
  invite                     = true
  invitation_message         = var.member.invitation_message
  disable_email_notification = var.member.disable_email_notification

  timeouts {
    create = "60s"
    update = "60s"
  }

  lifecycle {
    ignore_changes = [
      # For why this is necessary, see https://github.com/hashicorp/terraform-provider-aws/issues/8206
      invite,
      disable_email_notification,
      invitation_message,
    ]
  }
}

# Create GuardDuty invite accepter in the member account
resource "aws_guardduty_invite_accepter" "this" {
  detector_id       = aws_guardduty_detector.this.id
  master_account_id = data.aws_caller_identity.administrator.account_id

  depends_on = [aws_guardduty_member.this]
}

data "aws_guardduty_detector" "administrator" {
  provider = aws.administrator
}

data "aws_caller_identity" "administrator" {
  provider = aws.administrator
}
