variable "env" {
  type = string
}
##VPC
variable "vpc_conf" {
  type    = map(any)
  default = {}
}

variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
}
variable "public_subnets" {
  description = "A map of public subnet CIDR blocks keyed by their respective availability zones."
  type        = map(string)
}

variable "private_subnets" {
  description = "A map of private subnet CIDR blocks keyed by their respective availability zones."
  type        = map(string)
}

variable "instance_type" {
  description = "The EC2 instance type for the Auto Scaling Group."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to be used for the EC2 instances."
  type        = string
}


variable "domain_name" {
  type        = string
  description = "Domain name for SES verification"
}
