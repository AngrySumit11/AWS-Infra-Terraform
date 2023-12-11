variable "cloudhealth_external_id" {
  type = string
}

variable "s3_buckets_read" {
  type    = list(string)
  default = []
}

resource "aws_iam_role" "cloudhealth" {
  name               = "cloudhealth"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::454464851268:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${var.cloudhealth_external_id}"
        }
      }
    }
  ]
}
EOF

  tags = {
    terraform           = "iam/modules/cloudhealth"
    terraform-protected = "true"
  }
}

resource "aws_iam_policy" "cloudhealth-collector-policy-1" {
  name        = "cloudhealth-collector-policy-1"
  description = "cloudhealth"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:Describe*",
          "aws-portal:ViewBilling",
          "aws-portal:ViewUsage",
          "cloudformation:ListStacks",
          "cloudformation:ListStackResources",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:GetTemplate",
          "cloudfront:Get*",
          "cloudfront:List*",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetEventSelectors",
          "cloudtrail:ListTags",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "config:Get*",
          "config:Describe*",
          "config:Deliver*",
          "config:List*",
          "cur:Describe*",
          "dms:Describe*",
          "dms:List*",
          "dynamodb:DescribeTable",
          "dynamodb:List*",
          "ec2:Describe*",
          "ec2:GetReservedInstancesExchangeQuote",
          "ecs:List*",
          "ecs:Describe*",
          "elasticache:Describe*",
          "elasticache:ListTagsForResource",
          "elasticbeanstalk:Check*",
          "elasticbeanstalk:Describe*",
          "elasticbeanstalk:List*",
          "elasticbeanstalk:RequestEnvironmentInfo",
          "elasticbeanstalk:RetrieveEnvironmentInfo",
          "elasticfilesystem:Describe*",
          "elasticloadbalancing:Describe*",
          "elasticmapreduce:Describe*",
          "elasticmapreduce:List*",
          "es:List*",
          "es:Describe*",
          "firehose:ListDeliveryStreams",
          "firehose:DescribeDeliveryStream",
          "iam:List*",
          "iam:Get*",
          "iam:GenerateCredentialReport",
          "kinesis:Describe*",
          "kinesis:List*",
          "kms:DescribeKey",
          "kms:GetKeyRotationStatus",
          "kms:ListKeys",
          "lambda:List*",
          "logs:Describe*",
          "organizations:ListAccounts",
          "organizations:ListTagsForResource",
          "organizations:DescribeOrganization",
          "redshift:Describe*",
          "route53:Get*",
          "route53:List*",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetBucketLogging",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:GetBucketTagging",
          "s3:GetBucketVersioning",
          "s3:GetBucketWebsite",
          "s3:List*",
          "sagemaker:Describe*",
          "sagemaker:List*",
          "savingsplans:DescribeSavingsPlans",
          "sdb:GetAttributes",
          "sdb:List*",
          "ses:Get*",
          "ses:List*",
          "sns:Get*",
          "sns:List*",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues",
          "storagegateway:List*",
          "storagegateway:Describe*",
          "workspaces:Describe*"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DeleteSnapshot"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:StartInstances"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:StopInstances"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:RebootInstances"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:ModifyReservedInstances"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:PurchaseReservedInstancesOffering",
          "sts:GetFederationToken"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "rds:DescribeReservedDBInstancesOfferings",
          "rds:PurchaseReservedDBInstancesOffering"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:ReleaseAddress"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateSnapshot"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:ModifyReservedInstances",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:GetReservedInstancesExchangeQuote",
          "ec2:AcceptReservedInstancesExchangeQuote"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "savingsplans:DescribeSavingsPlansOfferings",
          "savingsplans:CreateSavingsPlan",
          "sts:GetFederationToken"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "cloudhealth-1" {
  role       = aws_iam_role.cloudhealth.name
  policy_arn = aws_iam_policy.cloudhealth-collector-policy-1.arn
}

data "aws_iam_policy_document" "s3-buckets-read" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = formatlist("arn:aws:s3:::%s", var.s3_buckets_read)
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = formatlist("arn:aws:s3:::%s/*", var.s3_buckets_read)
  }
}

resource "aws_iam_role_policy" "cloudhealth-s3-buckets-read" {
  name   = "cloudhealth-s3-buckets-read"
  role   = aws_iam_role.cloudhealth.name
  policy = data.aws_iam_policy_document.s3-buckets-read.json
  count  = length(var.s3_buckets_read) > 0 ? 1 : 0
}
