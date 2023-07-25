region = "eu-west-2"
project_name = "elearning"
vpc_cidr = "10.0.0.0/16"
instance_tenancy = "default"
web_pub_sub_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
app_priv_sub_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
enable_dns_hostnames = "true"

web_pub_sub_ids = ["subnet-02daf472dce3f43ee", "subnet-010fcf1c315d0b394"]
app_priv_sub_ids = ["subnet-03fa2403826094560", "subnet-05f6db8325709b1ca"]
all-subnet-ids = ["subnet-03fa2403826094560", "subnet-05f6db8325709b1ca", "subnet-02daf472dce3f43ee", "subnet-010fcf1c315d0b394"]
vpc_security_group_ids = "aws_security_group.elearning-sg.id"
container_image = "376716774817.dkr.ecr.eu-west-2.amazonaws.com/richiemage2"
key_name = "rock-key-pair"
ami = "ami-0a145236ee857b126"
instance_type = "t2.micro"
instance_count = "2"
alb_tls_cert_arn = "arn:aws:acm:eu-west-2:376716774817:certificate/7bf0f727-8f21-47af-989b-2cbfcab1992d"
