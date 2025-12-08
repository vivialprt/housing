resource "aws_s3_bucket" "etl_raw_layer" {
  bucket   = "etl-raw-layer-${var.env}-${var.s3_postfix}"

  tags = {
    "L2" = "ETL",
    "L3" = "storage",
    Environment = var.env
    Name = "etl-raw-layer"
  }
}

resource "aws_s3_bucket_public_access_block" "etl_raw_layer" {
  bucket   = aws_s3_bucket.etl_raw_layer.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
