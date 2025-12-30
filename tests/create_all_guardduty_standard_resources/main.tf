# Creates all GuardDuty standard resources for this account.
# - Creates a GuardDuty detector for this account
# - Creates two GuardDuty filters for this account
# - Creates a GuardDuty ipset for this account.  Must increase AWS limits to create more than one ipset.
# - Creates two GuardDuty threatintelsets for this account
# - Creates a GuardDuty publishing_destination for this account
# - Creates a GuardDuty Malware Protection for this account
# - Creates a GuardDuty Detector Feature for this account
module "guardduty_standard_resources" {
  source = "../../"

  enable                       = true
  enable_s3_protection         = true
  enable_kubernetes_protection = true
  enable_malware_protection    = true
  finding_publishing_frequency = "SIX_HOURS"

  filters = [
    {
      name        = "Filter1"
      description = "My Filter 1"
      rank        = 1
      action      = "ARCHIVE"
      tags = {
        environment = "testing"
      }
      criterion = [
        {
          field                 = "severity"
          equals                = ["4"]
          not_equals            = ["1"]
          greater_than          = null
          greater_than_or_equal = null
          less_than             = null
          less_than_or_equal    = null
        }
      ]
    },
    {
      name        = "Filter2"
      description = "My Filter 2"
      rank        = 1
      action      = "ARCHIVE"
      tags = {
        environment = "testing"
      }
      criterion = [
        {
          field                 = "accountId"
          equals                = ["123418158163", "123458158163"]
          not_equals            = ["223418158163", "223458158163"]
          greater_than          = null
          greater_than_or_equal = null
          less_than             = null
          less_than_or_equal    = null
          }, {
          field                 = "region"
          equals                = ["us-east-1"]
          not_equals            = null
          greater_than          = null
          greater_than_or_equal = null
          less_than             = null
          less_than_or_equal    = null
        }
      ]
    }
  ]

  threatintelsets = [
    {
      name     = "ThreatIntelSet1"
      activate = true
      format   = "TXT"
      location = "https://s3.amazonaws.com/${aws_s3_object.ThreatIntelSet1.bucket}/${aws_s3_object.ThreatIntelSet1.key}"
      tags = {
        environment = "testing"
      }
    },
    {
      name     = "ThreatIntelSet2"
      activate = true
      format   = "TXT"
      location = "https://s3.amazonaws.com/${aws_s3_object.ThreatIntelSet2.bucket}/${aws_s3_object.ThreatIntelSet2.key}"
      tags = {
        environment = "testing"
      }
    }
  ]

  ipsets = [
    {
      name     = "Ipset1"
      activate = true
      format   = "TXT"
      location = "https://s3.amazonaws.com/${aws_s3_object.ipSet1.bucket}/${aws_s3_object.ipSet1.key}"
      tags = {
        environment = "testing"
      }
    } /*,  Can only set one ipset without an AWS limit increase
    {
      name     = "Ipset2"
      activate = true
      format   = "TXT"
      location = "https://s3.amazonaws.com/${aws_s3_object.ipSet2.bucket}/${aws_s3_object.ipSet2.key}"
      tags = {
        environment = "testing"
      }
    }*/
  ]

  publishing_destination = {
    destination_arn  = aws_s3_bucket.bucket.arn
    kms_key_arn      = aws_kms_key.gd_key.arn
    destination_type = "S3"
  }

  protection_plans = {
    plan1 = {
      role = aws_iam_role.this.arn

      protected_resource = {
        s3_bucket = {
          bucket_name = aws_s3_bucket.bucket.bucket
        }
      }

      actions = {
        tagging = {
          status = "ENABLED"
        }
      }

      region = data.aws_region.current.region

      tags = {
        environment = "testing"
      }
    }
  }

  detector_features = [
    {
      name   = "LAMBDA_NETWORK_LOGS"
      status = "ENABLED"
      region = data.aws_region.current.region
    },
    {
      name   = "EKS_RUNTIME_MONITORING"
      status = "ENABLED"
      region = data.aws_region.current.region
      additional_configuration = {
        name   = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    },
  ]
}

data "aws_iam_policy_document" "bucket_pol" {
  statement {
    sid = "Allow PutObject"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow GetBucketLocation"
    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.bucket.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms_pol" {
  statement {
    sid = "Allow GuardDuty to encrypt findings"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow all users to modify/delete key (test only)"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = random_id.name.hex
  force_destroy = true
  tags = {
    environment = "testing"
  }
}

resource "aws_s3_bucket_policy" "gd_bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_pol.json
}

resource "aws_kms_key" "gd_key" {
  description             = "Temporary key for AccTest of TF"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_pol.json
}

resource "aws_s3_object" "ThreatIntelSet1" {
  acl     = "private"
  content = "10.0.0.0/8\n"
  bucket  = aws_s3_bucket.bucket.id
  key     = "ThreatIntelSet1"
}

resource "aws_s3_object" "ThreatIntelSet2" {
  acl     = "private"
  content = "10.10.0.0/8\n"
  bucket  = aws_s3_bucket.bucket.id
  key     = "ThreatIntelSet2"
}

resource "aws_s3_object" "ipSet1" {
  acl     = "private"
  content = "10.20.0.0/8\n"
  bucket  = aws_s3_bucket.bucket.id
  key     = "IpSet1"
}

resource "aws_s3_object" "ipSet2" {
  acl     = "private"
  content = "10.30.0.0/8\n"
  bucket  = aws_s3_bucket.bucket.id
  key     = "IpSet2"
}

resource "aws_iam_role" "this" {
  name = "guardduty-malware-protection-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "malware-protection-plan.guardduty.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Referece: https://docs.aws.amazon.com/guardduty/latest/ug/malware-protection-s3-iam-policy-prerequisite.html
resource "aws_iam_policy" "this" {
  name = "guardduty-malware-protection-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManagedRuleToSendS3EventsToGuardDuty"
        Effect = "Allow"
        Action = [
          "events:PutRule",
          "events:DeleteRule",
          "events:PutTargets",
          "events:RemoveTargets"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
        Condition = {
          StringLike = {
            "events:ManagedBy" = "malware-protection-plan.guardduty.amazonaws.com"
          }
        }
      },
      {
        Sid    = "AllowGuardDutyToMonitorEventBridgeManagedRule"
        Effect = "Allow"
        Action = [
          "events:DescribeRule",
          "events:ListTargetsByRule"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
      },
      {
        Sid    = "AllowPostScanTag"
        Effect = "Allow"
        Action = [
          "s3:PutObjectTagging",
          "s3:GetObjectTagging",
          "s3:PutObjectVersionTagging",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.bucket}/*"
        ]
      },
      {
        Sid    = "AllowEnableS3EventBridgeEvents"
        Effect = "Allow"
        Action = [
          "s3:PutBucketNotification",
          "s3:GetBucketNotification"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.bucket}"
        ]
      },
      {
        Sid    = "AllowPutValidationObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.bucket}/malware-protection-resource-validation-object"
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCheckBucketOwnership"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.bucket}"
        ]
      },
      {
        Sid    = "AllowMalwareScan"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.bucket}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
