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

resource "aws_db_instance" "example" {
    engine = "mysql"
    identifier_prefix = "terraform-up-and-running"
    allocated_storage = 10
    instance_class = "${var.db_size}"  
    name = "${var.db_name}_database"
    skip_final_snapshot = true
    username = "admin"
    password = "${var.db_password}"
}
