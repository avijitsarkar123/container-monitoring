provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "avijit-tf-states"
    key    = "docker-swarm-cluster-master-stack.tfstate"
    region = "us-east-1"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl.sh")}"

  vars {
    key = "value"
  }
}

resource "aws_launch_configuration" "docker-swarm-cluster-master-lc" {
  name                             = "docker-swarm-cluster-master-lc"
  image_id                         = "${var.ami_id}"
  instance_type                    = "${var.instance_type}"
  security_groups                  = ["${var.security_group_ids}"]
  vpc_classic_link_security_groups = []
  associate_public_ip_address      = false
  ebs_optimized                    = false
  key_name                         = "${var.key_pair_name}"
  iam_instance_profile             = "${var.iam_instance_profile}"
  user_data                        = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "docker-swarm-cluster-master-asg" {
  name                      = "docker-swarm-cluster-master"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  desired_capacity          = "${var.desired_capacity}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.docker-swarm-cluster-master-lc.name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]

  tag {
    key                 = "owner"
    value               = "Avijit Sarkar"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "docker-swarm-cluster-master"
    propagate_at_launch = true
  }
}
