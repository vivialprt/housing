data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id = data.aws_vpc.default.id

  tags = {
    "L2"        = "ETL"
    "L3"        = "security_group"
    Environment = var.env
    Name        = "ecs-tasks-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ecs_tasks_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}