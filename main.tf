# This file creates a standard GuardDuty configuration in a single AWS account.  These include a GuardDuty detector, filters, ipsets, threatintelsets, and publshing destination.  GuardDuty configurations that require multiple AWS accounts are not included in this module, and the terraform code for those configurations has been implemented in seperate submodeles (see the modules section of this project).
#
# - Creates a GuardDuty detector for this account
# - Creates one or more GuardDuty filters for this account if the filter var is not empty.
# - Creates one or more GuardDuty ipsets for this account if the ipset var is not empty.
# - Creates one or more GuardDuty threatintelsets for this account if the threatintelset var is not empty.
# - Creates a GuardDuty publishing_destination for this account if the publishing_destination var is not null.
#
# Prerequisites:  This publishing_destination resource assumes the S3 bucket associated with the destination arn exists and the required policies have been created to
# allow GuardDuty to access the bucket.  It also assumes the kms key associated with the kms key arn exists and has a policy that allows GuardDuty to to use it.

# Creates a GuardDuty detector for this account
resource "aws_guardduty_detector" "this" {
  enable                       = var.enable
  finding_publishing_frequency = var.finding_publishing_frequency

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

# Creates one or more GuardDuty filters for this account if the filter var is not empty.
resource "aws_guardduty_filter" "this" {
  for_each = { for filter in var.filters : filter.name => filter }

  detector_id = aws_guardduty_detector.this.id
  name        = each.value.name
  description = each.value.description
  rank        = each.value.rank
  action      = each.value.action
  tags        = each.value.tags
  finding_criteria {
    dynamic "criterion" {
      for_each = each.value.criterion
      content {
        field                 = criterion.value.field
        equals                = criterion.value.equals
        not_equals            = criterion.value.not_equals
        greater_than          = criterion.value.greater_than
        greater_than_or_equal = criterion.value.greater_than_or_equal
        less_than             = criterion.value.less_than
        less_than_or_equal    = criterion.value.less_than_or_equal
      }
    }
  }
}

# Creates one or more GuardDuty ipsets for this account if the ipset var is not empty.
resource "aws_guardduty_ipset" "this" {
  for_each = { for ipset in var.ipsets : ipset.name => ipset }

  detector_id = aws_guardduty_detector.this.id
  activate    = each.value.activate
  format      = each.value.format
  location    = each.value.location
  name        = each.value.name
  tags        = each.value.tags
}

# Creates one or more GuardDuty threatintelsets for this account if the threatintelset var is not empty.
resource "aws_guardduty_threatintelset" "this" {
  for_each = { for threatintelset in var.threatintelsets : threatintelset.name => threatintelset }

  detector_id = aws_guardduty_detector.this.id
  activate    = each.value.activate
  format      = each.value.format
  location    = each.value.location
  name        = each.value.name
  tags        = each.value.tags
}

# Creates a GuardDuty publishing_destination for this account if the publishing_destination var is not null.
# This resource assumes the S3 bucket associated with the destination arn exists and the required policies have been created to allow GuardDuty to access the bucket.  It also assumes the kms key associated with the kms key arn exists and has a policy that allows GuardDuty to to use it.
resource "aws_guardduty_publishing_destination" "this" {
  count = var.publishing_destination == null ? 0 : 1

  detector_id      = aws_guardduty_detector.this.id
  destination_arn  = var.publishing_destination.destination_arn
  kms_key_arn      = var.publishing_destination.kms_key_arn
  destination_type = "S3" # S3 is currently the only option for this
}

# Provides a resource to manage a GuardDuty malware protection plan.
resource "aws_guardduty_malware_protection_plan" "this" {
  for_each = var.protection_plans

  region = each.value.region
  role   = each.value.role
  tags   = each.value.tags

  protected_resource {
    s3_bucket {
      bucket_name     = each.value.protected_resource.s3_bucket.bucket_name
      object_prefixes = each.value.protected_resource.s3_bucket.object_prefixes
    }
  }

  actions {
    tagging {
      status = each.value.actions.tagging.status
    }
  }
}
