instance_type  = "t2.nano"
region         = "eu-west-1"
vpc_cidr       = "10.0.0.0/17"
web_pub_sub_cidrs = ["10.0.10.0/24", "10.0.12.0/24"]
app_priv_sub_cidrs = ["10.0.14.0/24", "10.0.16.0/24"]
ami            = "ami-0cd01c7fb16a9b497"

environment = "STAGING"

project_name = "elearning"
instance_tenancy = "default"

enable_dns_hostnames = "true"

web_pub_sub_ids = ["subnet-0e680e9c81842b66b", "subnet-0f50694b97a90a798"]
app_priv_sub_ids = ["subnet-0f0e62d38d6d8701b", "subnet-04cd6d5042528a8f5"]
all-subnet-ids = ["subnet-0e680e9c81842b66b", "subnet-0f50694b97a90a798", "subnet-0f0e62d38d6d8701b", "subnet-04cd6d5042528a8f5"]
vpc_security_group_ids = "aws_security_group.elearning-sg.id"
container_image = "376716774817.dkr.ecr.eu-west-2.amazonaws.com/richiemage2"
key_name = "rock-key-pair"

instance_count = "2"
alb_tls_cert_arn = "arn:aws:acm:eu-west-2:376716774817:certificate/7bf0f727-8f21-47af-989b-2cbfcab1992d"
