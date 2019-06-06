provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/Alex/.aws/credentials"
  profile = "default"
}
resource "aws_instance" "example" {
    ami = "ami-0c6b1d09930fac512" 
    instance_type = "t2.micro"

    tags{
        Name = "terraform-example"
    }
}
