resource "aws_ecs_cluster" "web_scraping" {
    name = "web-scraping"
    tags = {
        "L2" = "ETL",
        "L3" = "container_cluster",
        Environment = var.env
        Name = "web-scraping"
    }
}

module "aruodas_vilnius_incremental_task" {
    source = "./ecs_task_module"

    ecs_task_family    = "aruodas-vilnius-incremental"
    ecr_repo_url       = aws_ecr_repository.web_scraping.repository_url
    ecs_task_role_arn  = aws_iam_role.ecs_task_role.arn
    region             = var.region
    env                = var.env
    log_retention_days = 5
    account_id         = local.account_id

    ecs_container_environment = [
        {
            name  = "OUTPUT_BUCKET"
            value = aws_s3_bucket.etl_raw_layer.bucket
        },
        {
            name  = "OUTPUT_PREFIX"
            value = "aruodas_vilnius_appartments"
        }
    ]
}