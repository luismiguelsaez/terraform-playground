
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.cluster_name
}

# IAM role to attach to the task definition
resource "aws_iam_role" "awslogs" {
  # As we're giving permissions only to the CW log group of the current region, region name is added to the IAM resources to avoid naming conflicts
  name = format("ecs-cloudwatch-%s-%s", var.cluster_name, data.aws_region.current.name)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# IAM policy to allow sending logs to the created log group
resource "aws_iam_role_policy" "awslogs" {
  # As we're giving permissions only to the CW log group of the current region, region name is added to the IAM resources to avoid naming conflicts
  name = format("ecs-cloudwatch-%s-%s", var.cluster_name, data.aws_region.current.name)
  role = aws_iam_role.awslogs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = [ 
          "arn:aws:logs:${data.aws_region.current.name}:*:destination:*", 
          "arn:aws:logs:${data.aws_region.current.name}:*:${aws_cloudwatch_log_group.this.name}:*",
          "arn:aws:logs:${data.aws_region.current.name}:*:${aws_cloudwatch_log_group.this.name}:log-stream:*" ]
      },
    ]
  })
}

resource "aws_ecs_task_definition" "web" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # Specified as documented here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = 256
  memory = 512

  # Skipping IAM role, as the containers won't have to connect to AWS services
  #task_role_arn            = "${aws_iam_role.task.arn}"
  execution_role_arn       = aws_iam_role.awslogs.arn

  container_definitions = jsonencode([
    {
      name         = "location"
      image        = "luismiguelsaez/location:latest"
      cpu          = 125
      memory       = 128
      essential    = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_lb_target_group" "web" {
  name        = format("ecs-%s-web",var.service_name)
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_ecs_service" "web" {
  name          = var.service_name
  cluster       = aws_ecs_cluster.this.arn
  launch_type   = "FARGATE"
  desired_count = var.service_desired_count

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = var.private_subnets
  }

  task_definition = aws_ecs_task_definition.web.arn

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "location"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  name               = "cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    target_value       = 80
  }
}