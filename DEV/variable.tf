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
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_priv_sub_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "enable_dns_hostnames" {
  default = true
}

variable "web_pub_sub_ids" {
  default = ["subnet-0e26fc68437abd587", "subnet-0933798866cb42cac"]
  type    = list(any)
}

variable "app_priv_sub_ids" {
  default = ["subnet-0c2b173033193d1fd", "subnet-0c4b14b6f45206a55"]
  type    = list(any)
}

variable "all-subnet-ids" {
  type    = list(any)
  default = ["subnet-0e26fc68437abd587", "subnet-0933798866cb42cac", "subnet-0c2b173033193d1fd", "subnet-0c4b14b6f45206a55"]
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
  default = "DEV"
  description = "making my environment a variable"
  type = string
}

