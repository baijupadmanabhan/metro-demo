variable "aws_region" {
    default = "us-west-2"
}

variable "vpc-cidr" {}

variable "vpc-id" {}

variable "private-subnet-prefix" {}

variable "ingress-subnet-prefix" {}

variable "egress-subnet-prefix" {}

variable "data-subnet-prefix" {}

variable "env_name" {}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "ingress_rules" {
  description = "List of ingress rules"
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules"
  default     = []
}

data "aws_availability_zones" "azs" {
  state = "available"
}
