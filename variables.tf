variable "aws_access_key" {
  description = "The AWS access key."
}

variable "aws_secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "availability_zones" {
  description = "The availability zone"
  default = "us-east-1b"
}

variable "vpc_subnet_availability_zone" {
  description = "The VPC subnet availability zone"
  default = "us-east-1b"
}
