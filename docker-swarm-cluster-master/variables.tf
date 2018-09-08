variable "ami_id" {
  default = "ami-759bc50a"
}

variable "subnet_ids" {
  default = "subnet-146fb13a, subnet-935e82cf, subnet-7776153d"
}

variable "security_group_ids" {
  default = "sg-64112f2e"
}

variable "instance_type" {
  default = "t2.small"
}

variable "key_pair_name" {
  default = "avijit-personal-mac"
}

variable "iam_instance_profile" {
  default = "app-instance"
}

variable "max_size" {
  default = "1"
}

variable "desired_capacity" {
  default = "1"
}

variable "min_size" {
  default = "1"
}

variable "health_check_grace_period" {
  default = "300"
}

variable "health_check_type" {
  default = "ELB"
}

variable "vpc_zone_identifier" {
  default = ""
}
