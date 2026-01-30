provider "aws" {
  region  = "us-west-2"
  profile = "prod-us"
}

terraform {
  backend "s3" {
    bucket         = "anvorob-terraform" 
    key            = "aws-infra/terraform.tfstate" 
    region         = "us-east-1"
    
    encrypt        = true
  }
}

module "app_vpc" {
  source = "git::git@github.com:anvorob/vpc_module_tf.git"

  cidr = "10.0.0.0/23"
  name = "production"
  subnets = {
    int_a = "10.0.0.0/24"
    int_b = "10.0.1.0/24"
    }
}
