variable "region" {
  default     = "eu-west-2"
  description = "making region a variable"
}

variable "project_name" {
  default = "elearning"

}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "making vpc_cidr a variable"
}

variable "instance_tenancy" {
  default     = "default"
  description = "making instance tenancy a variable"
}



variable "web_pub_sub_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.13.0/24"]
}

variable "app_priv_sub_cidrs" {
  type    = list(string)
  default = ["10.0.15.0/24", "10.0.17.0/24"]
}

variable "enable_dns_hostnames" {
  default = true
}

variable "web_pub_sub_ids" {
  default = ["subnet-06d52b90b98fb71ff", "subnet-095960016d097912b"]
  type    = list(any)
}

variable "app_priv_sub_ids" {
  default = ["subnet-07f8f92ec2e5a71d5", "subnet-0c191b4c1fb771848"]
  type    = list(any)
}

variable "all-subnet-ids" {
  type    = list(any)
  default = ["subnet-06d52b90b98fb71ff", "subnet-095960016d097912b", "subnet-07f8f92ec2e5a71d5", "subnet-0c191b4c1fb771848"]
}


variable "vpc_security_group_ids" {
  default = "aws_security_group.elearning-sg.id"
}

variable "container_image" {
  default = "376716774817.dkr.ecr.eu-west-2.amazonaws.com/richiemage2"
}

variable "key_name" {
  default = "rock-key-pair"
}

variable "ami" {
  default = "ami-0a145236ee857b126"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = "2"
}

variable "alb_tls_cert_arn" {
default = "arn:aws:acm:eu-west-2:376716774817:certificate/7bf0f727-8f21-47af-989b-2cbfcab1992d"
description = "making tls certificate a variable"
}

variable "environment" {
  default = "PROD"
  description = "making my environment a variable"
  type = string
}