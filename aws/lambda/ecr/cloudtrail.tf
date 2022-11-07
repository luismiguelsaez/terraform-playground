
locals {
  cloudtrail_s3_key_prefix = format("cloudtrail-%s-ecr", var.environment)
}

resource "aws_cloudtrail" "this" {
  name                          = format("%s-ecr", var.environment)
  s3_bucket_name                = aws_s3_bucket.this.id
  s3_key_prefix                 = local.cloudtrail_s3_key_prefix
  include_global_service_events = false

  enable_logging = true
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.this.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudwatch.arn

  is_multi_region_trail = false
}

resource "aws_cloudwatch_log_group" "this" {
  name = format("%s-ecr", var.environment)
}

resource "random_string" "random" {
  length  = 16
  lower   = true
  upper   = false
  special = false
}

resource "aws_iam_role" "cloudwatch" {
  name = format("%s-ecr-cloudwatch", var.environment)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "test-cloudtrail-cloudwatch"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]    
}
EOF
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = format("%s-%s-logs", random_string.random.result, var.environment)
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.s3_bucket_lifecycle_enable ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id = "all"

    filter {}

    status = "Enabled"

    transition {
      days          = var.s3_bucket_lifecycle["STANDARD_IA"]
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.s3_bucket_lifecycle["DELETE"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.this.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.this.arn}/${local.cloudtrail_s3_key_prefix}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
