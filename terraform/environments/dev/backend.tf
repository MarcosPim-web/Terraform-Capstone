terraform {
  backend "s3" {
    bucket         = "realtime-data-platform-dev-tfstate-marcos"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "realtime-data-platform-dev-tflock"
    encrypt        = true
  }
}