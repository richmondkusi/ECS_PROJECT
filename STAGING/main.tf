module "staging-module" {
  source = "../DEV"
  environment = var.environment
  web_pub_sub_ids = var.web_pub_sub_ids
  app_priv_sub_ids = var.app_priv_sub_ids
  all-subnet-ids = var.all-subnet-ids
  instance_type  = var.instance_type
  region         = var.region
  vpc_cidr       = var.vpc_cidr
  web_pub_sub_cidrs = var.web_pub_sub_cidrs
  app_priv_sub_cidrs = var.app_priv_sub_cidrs
  ami            = var.ami
 
}