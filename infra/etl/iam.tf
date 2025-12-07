resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_role_policy" {
    name = "eventbridge-policy"
    role = aws_iam_role.eventbridge_role.id
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = [
            "iam:PassRole"
          ]
          Resource = [
            "arn:aws:iam::*:role/ecsTaskExecutionRole",
            aws_iam_role.ecs_task_role.arn
          ]
        },{
          Effect   = "Allow"
          Action   = [
            "ecs:RunTask"
          ]
          Resource = "*"
        }]
    })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
    name = "ecs-task-s3-policy"
    role = aws_iam_role.ecs_task_role.id
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Effect   = "Allow"
        Action   = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket"
        ]
        Resource = [
            "${aws_s3_bucket.etl_raw_layer.arn}",
            "${aws_s3_bucket.etl_raw_layer.arn}/*"
        ]
        }]
    })
}