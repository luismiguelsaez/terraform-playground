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
              "ecr:CreateRepository",
              "ecr:DescribeRepositories"
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
