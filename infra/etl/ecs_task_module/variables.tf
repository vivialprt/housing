variable "ecs_task_family" {
    description = "The family of the ECS task definition"
    type        = string
}

variable "account_id" {
    description = "AWS Account ID"
    type        = string
}

variable "ecs_task_role_arn" {
    description = "The ARN of the IAM role that the task can assume"
    type        = string
}

variable "ecs_container_name" {
    description = "The name of the ECS container"
    type        = string
    default = "web-scraping"
}

variable "ecr_repo_url" {
    description = "The URL of the ECR repository"
    type        = string
}

variable "ecs_container_environment" {
    description = "Environment variables for the ECS container"
    type        = list(object({
        name  = string
        value = string
    }))
    default = []
}

variable "log_retention_days" {
    description = "CloudWatch log retention in days"
    type        = number
    default     = 7
}

variable "ecs_task_cpu" {
    description = "The number of cpu units reserved for the container"
    type        = string
    default     = "256"
}

variable "ecs_task_memory" {
    description = "The amount of memory (in MB) reserved for the container"
    type        = string
    default     = "512"
}

variable "region" {
    description = "AWS region"
    type        = string
    default     = "eu-central-1"
}

variable "env" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string
}