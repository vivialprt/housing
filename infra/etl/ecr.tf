resource "aws_ecr_repository" "etl_repository" {
  name = "etl-repository-${var.ecr_postfix}"

  tags = {
    "L2" = "ETL",
    "L3" = "container_registry",
    Environment = var.env
    Name = "etl-repository"
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.etl_repository.repository_url
}

output "ecr_repository_name" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.etl_repository.name
}