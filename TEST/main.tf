module "test-module" {
  source = "../DEV"
  environment = var.environment
  web_pub_sub_ids = ["subnet-0cd102b1760f1aee3", "subnet-0046e7441bda8bfdf"]
  app_priv_sub_ids = ["subnet-01856b8c90e3594d5", "subnet-092757fbccfbfdd3c"]
  all-subnet-ids = var.all-subnet-ids
}