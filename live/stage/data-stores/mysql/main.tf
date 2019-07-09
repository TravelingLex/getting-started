provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials" 
  profile = "personal" 
}
terraform {
  required_version = ">= 0.12, < 0.13"
  backend "s3"{
    bucket = "terraforming-up-and-running-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    profile = "personal"
    shared_credentials_file = "~/.aws/credentials"
  }
}
module "database" {
  source = "git@github.com:TravelingLex/getting-started-modules.git//data-stores/mysql"  
  
  db_name = "staging"
  db_size = "db.t2.micro"
  db_password = "320042sb1290"
}
