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
  "source": [
    "aws.ecr"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ecr.amazonaws.com"
    ],
    "eventName": [
      "InitiateLayerUpload"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "lambda" {
  arn  = aws_lambda_function.ecr-repository.arn
  rule = aws_cloudwatch_event_rule.ecr-push-fail.id
}

resource "aws_lambda_function" "ecr-repository" {
  filename      = "src/lambda_function_payload.zip"
  function_name = "ecr-repository"
  role          = aws_iam_role.lambda-ecr-repository.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("src/lambda_function_payload.zip")

  runtime = "python3.9"
}

resource "aws_lambda_permission" "allow-eventbridge" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecr-repository.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr-push-fail.arn
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
        },
        {
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
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
