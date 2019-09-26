provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
      bucket         = "metro-demo-terraform-state"
      key            = "demostate/terraform.tfstate"
      region         = "us-west-2"
  }
}

module "preprod-vpc" {
    source = "../modules/vpc"
    vpc-id = "${module.preprod-vpc.vpc_id}"
    vpc-cidr = "10.0.0.0/16"
    private-subnet-prefix = "10.0"
    ingress-subnet-prefix = "10.0"
    egress-subnet-prefix = "10.0"
    data-subnet-prefix = "10.0"
    aws_region = "us-west-2"
    env_name = "pre-prod"

    public_inbound_acl_rules = concat(
      local.network_acls["default_inbound"],
      local.network_acls["public_inbound"],
    )

    public_outbound_acl_rules = concat(
      local.network_acls["default_outbound"],
      local.network_acls["public_outbound"],
    )
}

module "web-ec2" {
    source = "../modules/ec2"
    image_id = "ami-04b762b4289fba92b"
    instance_type = "t2.micro"
    key_name = "demo-key"

    #subnet-id = "${module.preprod-vpc.private_subs}"
    env_name = "pre-prod"
    
    vpc-id                    = "${module.preprod-vpc.vpc_id}"
    private_subnet_ids        = "${element(module.preprod-vpc.private_subs,0)}"
    ingress_subnet_ids         = "${element(module.preprod-vpc.ingress_subs,0)}"
    app_sg_ids                = "${element(module.preprod-vpc.app_sg,0)}"
    alb_sg_ids                = "${element(module.preprod-vpc.alb_sg,0)}"
    bastion_sg_ids            = "${element(module.preprod-vpc.bastion_sg,0)}"
    alb_target_grp_name       = "demo-target-grp"
    alb_name                  = "demo-alb"
    health_check_type         = "EC2"
    min_size                  = 0
    max_size                  = 1
    desired_capacity          = 1
    wait_for_capacity_timeout = 0
}


locals {
  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 32768
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound = [
    {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 210
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 220
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 230
        rule_action = "allow"
        from_port   = 0
        to_port     = 65525
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 240
        rule_action = "allow"
        from_port   = 0
        to_port     = 53
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },

    ]



    egress_inbound = [
    {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    egress_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 210
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 220
        rule_action = "allow"
        from_port   = 123
        to_port     = 123
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 230
        rule_action = "allow"
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 240
        rule_action = "allow"
        from_port   = 53
        to_port     = 53
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }

  
}