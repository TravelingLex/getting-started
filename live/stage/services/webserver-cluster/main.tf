provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "personal"
}

terraform {
  required_version = ">= 0.12, < 0.13"
  backend "s3" {
    bucket                  = "terraforming-up-and-running-state"
    key                     = "stage/services/webserver-cluster/terraform.tfstate"
    region                  = "us-east-1"
    dynamodb_table          = "terraform-state-lock"
    profile                 = "personal"
    shared_credentials_file = "~/.aws/credentials"
  }
}

module "webserver_cluster" {
  source = "git@github.com:TravelingLex/getting-started-modules.git//services/webserver-cluster"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraforming-up-and-running-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
  enable_autoscaling = false
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = "${module.webserver_cluster.elb_security_group_id}"

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

