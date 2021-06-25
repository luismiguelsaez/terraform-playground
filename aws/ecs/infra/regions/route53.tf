# To achieve good response times, we're going to create latency-based DNS records
# Added healthcheck too, to achieve HA in case of LBs failure

resource "aws_route53_health_check" "status_ireland" {
  fqdn              = module.ecs_ireland.lb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/status"
  failure_threshold = "5"
  request_interval  = "30"
}

resource "aws_route53_health_check" "status_nvirginia" {
  fqdn              = module.ecs_nvirginia.lb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/status"
  failure_threshold = "5"
  request_interval  = "30"
}

resource "aws_route53_record" "latency_ireland" {
  zone_id = var.zone_id
  name    = "ecs-web"
  type    = "CNAME"
  ttl     = "5"
  set_identifier = "ecs-web-eu-west-1"

  health_check_id = aws_route53_health_check.status_ireland.id

  latency_routing_policy {
    region = "eu-west-1"
  }

  records = [
    module.ecs_ireland.lb_dns_name
  ]
}

resource "aws_route53_record" "latency_nvirginia" {
  zone_id = var.zone_id
  name    = "ecs-web"
  type    = "CNAME"
  ttl     = "5"
  set_identifier = "ecs-web-us-east-1"

  health_check_id = aws_route53_health_check.status_nvirginia.id

  latency_routing_policy {
    region = "us-east-1"
  }

  records = [
    module.ecs_nvirginia.lb_dns_name
  ]
}