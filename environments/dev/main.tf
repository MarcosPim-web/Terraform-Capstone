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