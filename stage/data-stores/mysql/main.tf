terraform {
  require_version = ">= 0.12, < 0.13"
  backend "s3"{
    bucket = "terraforming-up-and-running-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    profile = "personal"
    shared_credentials_file = "/Users/Alexm/.aws/credentials"
  }
}
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/Alex/.aws/credentials"
  profile = "personal"
}

resource "aws_db_instance" "example" {
    engine = "mysql"
    identifier_prefix = "terraform-up-and-running"
    allocated_storage = 10
    instance_class = "db.t2.micro"  
    name = "example_database"
    skip_final_snapshot = true
    username = "admin"
    password = "${var.db_password}"
}
