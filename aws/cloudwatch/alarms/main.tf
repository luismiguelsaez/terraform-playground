
locals {
  metric_namespace = "http"
  metric_name = "HTTP5xxErrorCount"
}

resource "aws_cloudwatch_log_group" "webserver_http" {
  name = "webserver_http"
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