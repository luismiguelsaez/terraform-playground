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

resource "aws_ecr_repository" "test" {
  name                 = "test"
  image_tag_mutability = "IMMUTABLE"
}

output "ecr_repository" {
  value = aws_ecr_repository.test.repository_url
}

resource "aws_cloudwatch_event_rule" "ecr-push-fail" {
  name        = "capture-ecr-push-fail"
  description = "Capture ECR event for failed push to repository"

  event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ]
}
EOF
}

#resource "aws_cloudwatch_event_target" "example" {
#  arn  = aws_lambda_function.example.arn
#  rule = aws_cloudwatch_event_rule.ecr-push-fail.id
#}

resource "aws_lambda_function" "ecr-repository" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.lambda-ecr-repository.arn
  handler       = "lambda_handler"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.9"
}

resource "aws_iam_role" "lambda-ecr-repository" {
  name = "ecr-repository"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = "ecr-repository"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateRepository",
            "Effect": "Allow",
            "Action": [
              "ecr:CreateRepository"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  }
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
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test-cloudtrail-cloudwatch"
  role = aws_iam_role.cloudtrail-cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.ecr.arn}:*"
      },
    ]
  })
}

resource "aws_s3_bucket" "ecr" {
  bucket        = format("%s-test-ecr",random_string.random.result)
  force_destroy = true
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
