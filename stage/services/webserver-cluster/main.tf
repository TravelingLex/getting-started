terraform {
  require_version = ">= 0.12, < 0.13"
  backend "s3"{
    bucket = "terraforming-up-and-running-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
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
#resource "aws_instance" "example" {
#    ami = "${var.web_image_id}" 
#    instance_type = "t2.micro"
#    vpc_security_group_ids = ["${aws_security_group.instance.id}"]

#    user_data = <<-EOF
#                #!/bin/bash
#                echo "Hello, World" > index.html
#                nohup busybox httpd -f -p "${var.server_port}" &
#                EOF
#
#
#    tags{
#        Name = "terraform-example"
#    }
#}
resource "aws_launch_configuration" "example" {
    image_id = "${var.web_image_id}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = "${data.template_file.user_data.rendered}"

    lifecycle{
        create_before_destroy = true
    }
}
resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]

    load_balancers = ["${aws_elb.example.name}"]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key     = "Name"
        value   = "terraform-asg-example"
        propagate_at_launch = true
    }
}
resource "aws_elb" "example" {
    name = "terraform-asg-example"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb.id}"]

    listener{
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check{
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress{
      from_port = "${var.server_port}"
      to_port = "${var.server_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "elb" {
    name = "terraform-example-elb"

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
data "aws_availability_zones" "all" {}
data "terraform_remote_state" "db" {
  backend = "s3"

  config{
      bucket = "terraforming-up-and-running-state"
      key = "stage/data-stores/mysql/terraform.tfstate"
      region = "us-east-1"
      profile = "personal"
      shared_credentials_file = "/Users/Alexm/.aws/credentials"
  }
}
data "template_file" "user_data" {
    template = "${file("user-data.sh")}"

    vars {
        server_port = "${var.server_port}"
        db_address  = "${data.terraform_remote_state.db.address}"
        db_port     = "${data.terraform_remote_state.db.port}"
    }
}
