resource "aws_cloudtrail" "ecr" {
  name                          = "test-ecr"
  s3_bucket_name                = aws_s3_bucket.ecr.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false

  enable_logging = true
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.ecr.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail-cloudwatch.arn

  is_multi_region_trail = false
}

resource "aws_cloudwatch_log_group" "ecr" {
  name = "test-ecr"
}

resource "random_string" "random" {
  length  = 16
  lower   = true
  upper   = false
  special = false
}

resource "aws_iam_role" "cloudtrail-cloudwatch" {
  name = "test-cloudtrail-cloudwatch"

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

resource "aws_s3_bucket" "ecr" {
  bucket        = format("%s-test-ecr",random_string.random.result)
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.ecr.id

  rule {
    id = "all"

    filter {}

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket_policy" "ecr" {
  bucket = aws_s3_bucket.ecr.id
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
            "Resource": "${aws_s3_bucket.ecr.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.ecr.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
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
