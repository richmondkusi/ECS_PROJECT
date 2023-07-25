region = "eu-west-2"
project_name = "elearning"
vpc_cidr = "10.0.0.0/16"
instance_tenancy = "default"
web_pub_sub_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
app_priv_sub_cidrs = ["10.0.12.0/24", "10.0.13.0/24"]
enable_dns_hostnames = "true"

web_pub_sub_ids = ["subnet-07196b2de00f7a33c", "subnet-0bec882a258ba2efb"]
app_priv_sub_ids = ["subnet-01943c509bb8c93f1", "subnet-0fc16056b92fa820a"]
all-subnet-ids = ["subnet-07196b2de00f7a33c", "subnet-0bec882a258ba2efb", "subnet-01943c509bb8c93f1", "subnet-0fc16056b92fa820a"]
vpc_security_group_ids = ["aws_security_group.elearning-sg.id"]
container_image = "376716774817.dkr.ecr.eu-west-2.amazonaws.com/richiemage2"
key_name = "rock-key-pair"
ami = "ami-0a145236ee857b126"
instance_type = "t2.micro"
instance_count = "2"
alb_tls_cert_arn = "arn:aws:acm:eu-west-2:376716774817:certificate/7bf0f727-8f21-47af-989b-2cbfcab1992d"
environment = "TEST"