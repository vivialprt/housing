resource "aws_ecr_repository" "web_scraping" {
  name = "web-scraping-${var.env}"

  tags = {
    "L2" = "ETL",
    "L3" = "container_registry",
    Environment = var.env
    Name = "web_scraping"
  }
}

output "web_scraping_repo_url" {
  description = "URL of the web scraping ECR repository"
  value       = aws_ecr_repository.web_scraping.repository_url
}
