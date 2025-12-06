
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
}