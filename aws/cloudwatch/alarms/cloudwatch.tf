
locals {
  metric_namespace = "apps/web/http"
  metric_name      = "HTTP5xxErrorCount"
}

resource "aws_sns_topic" "general_alarms" {
  name = "general_alarms"
}

resource "aws_sns_topic_subscription" "general_alarms_sns" {
  topic_arn = aws_sns_topic.general_alarms.arn
  protocol  = "email"
  endpoint  = "luismiguelsaez83@gmail.com"
}

resource "aws_cloudwatch_log_group" "webserver_http" {
  name = local.metric_namespace
}

resource "aws_cloudwatch_log_metric_filter" "http_errors_5xx" {
  name           = "http_errors_5xx"
  pattern        = "[host, logName, user, timestamp, request, statusCode=5*, size]"
  log_group_name = aws_cloudwatch_log_group.webserver_http.name

  metric_transformation {
    name      = local.metric_name
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "http_errors_5xx" {
  alarm_name                = "http_errors_5xx"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = local.metric_name
  namespace                 = local.metric_namespace
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "5"
  alarm_description         = "This metric monitors HTTP 5xx error count"
  insufficient_data_actions = []
}