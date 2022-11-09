resource "aws_cloudwatch_event_bus" "this" {
  name = "cloudtrail-messages"
}

resource "aws_cloudwatch_event_rule" "ecr-push-fail" {
  name        = "capture-ecr-push-fail"
  description = "Capture ECR event for failed push to repository"

  event_bus_name = aws_cloudwatch_event_bus.this.name

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
