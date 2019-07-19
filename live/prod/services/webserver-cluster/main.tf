provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials" 
  profile = "personal" 
}
terraform {
  required_version = ">= 0.12, < 0.13"
  backend "s3"{
    bucket = "terraforming-up-and-running-state"
    key = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    profile = "personal"
    shared_credentials_file = "~/.aws/credentials"
  }
}
module "webserver_cluster" {
  source = "git@github.com:TravelingLex/getting-started-modules.git//services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "terraforming-up-and-running-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "m4.large"
  min_size = 2
  max_size = 10
  enable_autoscaling = true
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = "${var.enable_autoscaling}"

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"

  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = "${var.enable_autoscaling}"

  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}


