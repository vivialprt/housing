
resource "aws_ecs_task_definition" "task" {
    family                   = var.ecs_task_family
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.ecs_task_cpu
    memory                   = var.ecs_task_memory
    execution_role_arn       = "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole"
    task_role_arn            = var.ecs_task_role_arn

    container_definitions = jsonencode([
        {
            name      = var.ecs_container_name
            image     = "${var.ecr_repo_url}:latest"
            essential = true
            cpu       = tonumber(var.ecs_task_cpu)

            environment = var.ecs_container_environment

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
                    "awslogs-region"        = var.region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    ])

    tags = {
        "L2" = "ETL",
        "L3" = "ecs_task_definition",
        Environment = var.env
        Name = var.ecs_task_family
    }
}

resource "aws_cloudwatch_log_group" "log_group" {
    name              = "/ecs/${var.ecs_task_family}"
    retention_in_days = var.log_retention_days

    tags = {
        "L2" = "ETL",
        "L3" = "ecs_task_logs",
        Environment = var.env
        Name = "${var.ecs_task_family}-logs"
    }
}

resource "aws_cloudwatch_event_rule" "ecs_task_schedule" {
    name                = "${var.ecs_task_family}-trigger"
    description         = "Schedule to run ECS task ${var.ecs_task_family}"
    schedule_expression = var.task_schedule

    tags = {
        "L2" = "ETL",
        "L3" = "eventbridge_rule",
        Environment = var.env
        Name = "${var.ecs_task_family}-schedule"
    }
}

resource "aws_cloudwatch_event_target" "ecs_task_eventbridge_target" {

    arn      = var.task_cluster_arn
    rule     = aws_cloudwatch_event_rule.ecs_task_schedule.name
    role_arn = var.eventbridge_role_arn

    ecs_target {
        task_definition_arn = aws_ecs_task_definition.task.arn
        launch_type         = "FARGATE"
        network_configuration {
            subnets         = var.task_subnets
            security_groups = [var.task_security_group]
            assign_public_ip = true
        }
        platform_version = "LATEST"
    }
}