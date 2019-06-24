provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/Alexm/.aws/credentials" 
  profile = "personal" 
}
module "database" {
  source = "../../../modules/data-stores/mysql"
  
  db_name = "production_db"
  db_size = "db.t2.micro"
  db_password = "320042sB1290"
}