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

module "security_groups"
{

  name = "ECICE"
  description = "Allows SSH outbound traffic to the private instance"
  vpc_id = app_vpc.id
  
    egress_rules = map(object({
      source_security_group_id = ""
      from_port         = 22
      ip_protocol       = tcp
      to_port           = 22
    }))
}

module "ec2_instance" {
  source = "git::git@github.com:anvorob/ec2_module_tf.git"

subnet_id = 
key_name = 
sg_list = []
instance_type = "t2.micro"
name = "Test instance"
}
