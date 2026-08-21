module "network" {
  source = "../../modules/network"

  environment = var.environment
  region      = var.region
  vpc_cidr    = var.vpc_cidr
}

module "identity" {
  source = "../../modules/identity"

  environment   = var.environment
  bucket_name   = var.bucket_name
  bucket_prefix = var.bucket_prefix
}

resource "aws_s3_bucket" "raw" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Layer       = "Bronze"
  }
}

module "kinesis" {
  source = "../../modules/kinesis"

  environment     = var.environment
  project_name    = var.project_name
  shard_count     = 2
  raw_bucket_name = aws_s3_bucket.raw.bucket
  raw_bucket_arn  = aws_s3_bucket.raw.arn
}

module "flink" {
  source = "../../modules/flink"

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  kinesis_stream_arn = module.kinesis.kinesis_stream_arn

  jar_path = "${path.root}/../../flink/target/realtime-flink-processing-1.0.0.jar"
}