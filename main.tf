provider "aws" {
  region  = "us-west-2"
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
    #int_b = "10.0.1.0/24"
    }
}

module "ec2_security_group" {
  source = "git::git@github.com:anvorob/security_group_module_tf.git"
  name = "MyPrivateSecurityGroup"
  description = "MyPrivateSecurityGroup"
  vpc_id = module.app_vpc.vpc_id
  ingress_rules = {}
  egress_rules = {}
}

module "ecice_security_group" {
  source = "git::git@github.com:anvorob/security_group_module_tf.git"
  name = "ECICE"
  description = "Allows SSH outbound traffic to the private instance"
  vpc_id = module.app_vpc.vpc_id
  ingress_rules = {}
  egress_rules = {
    rule_1 = {
      source_security_group_id = module.ec2_security_group.id
      from_port         = 22
      ip_protocol       = "tcp"
      to_port           = 22
    }}
}


module "ec2_instance" {
  source = "git::git@github.com:anvorob/ec2_module_tf.git"
  subnet_id = module.app_vpc.subnet_objs["int_a"].id
  key_name = "EC2_test_key"
  sg_list = [module.ec2_security_group.id]
  instance_type = "t2.micro"
  ami_id = "ami-055a9df0c8c9f681c"
  name = "Test instance"
}


resource "aws_ec2_instance_connect_endpoint" "example" {
  subnet_id          = module.app_vpc.subnet_objs["int_a"].id
  security_group_ids = [module.ecice_security_group.id]

  tags = {
    Name = "my-eic-endpoint"
  }
}
