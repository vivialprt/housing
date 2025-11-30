resource "aws_ecr_repository" "aruodas_vilnius_appartments_incremental" {
  name = "aruodas_vilnius_appartments_incremental"

  tags = {
    "L2" = "ETL",
    "L3" = "container_registry",
    Environment = var.env
    Name = "aruodas_vilnius_appartments_incremental"
  }
}

output "aruodas_vilnius_appartments_incremental_repo_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.aruodas_vilnius_appartments_incremental.repository_url
}
