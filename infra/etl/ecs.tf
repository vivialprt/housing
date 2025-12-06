resource "aws_ecs_cluster" "web_scraping" {
    name = "web-scraping"
    tags = {
        "L2" = "ETL",
        "L3" = "container_cluster",
        Environment = var.env
        Name = "web-scraping"
    }
}
