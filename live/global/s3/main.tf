terraform {
  require_version = ">= 0.12, < 0.13"
  backend "s3"{
    bucket = "terraforming-up-and-running-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    profile = "personal"
    shared_credentials_file = "/Users/Alexm/.aws/credentials"
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials" 
  profile = "personal" 
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}"

  versioning{
    enabled = true
  }
  server_side_encryption_configuration{
    rule {
      apply_server_side_encryption_by_default{
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name = "${var.table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
