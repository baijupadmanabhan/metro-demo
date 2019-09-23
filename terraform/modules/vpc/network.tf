#################################################################
# VPC resorces 
# Creating VPC and IGW
#################################################################

resource "aws_vpc" "vpc-demo" {
  cidr_block = "${var.vpc-cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-demo"
    Environment = "${var.env_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc-demo.id}"
  tags  = {
    Environment = "${var.env_name}"
  }
}

#################################################################
# Subnet resources. 
# Ingress and Egress are public subnets.
# Private and Data are private subnets.
#################################################################

resource "aws_subnet" "private-subnet" {
    count = "${length(data.aws_availability_zones.azs.names)}"
    vpc_id     = "${var.vpc-id}"
    cidr_block = "${var.private-subnet-prefix}.${count.index+10+1}.0/24"
    availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
    tags = {
        Name = "private-subnet-${count.index+1}"
        Tier = "Private"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "ingress-subnet" {
    count = "${length(data.aws_availability_zones.azs.names)}"
    vpc_id     = "${var.vpc-id}"
    cidr_block = "${var.ingress-subnet-prefix}.${count.index+20+1}.0/24"
    availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
    map_public_ip_on_launch = true

    tags = {
        Name = "ingress-subnet-${count.index+1}"
        Tier = "Ingress"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "egress-subnet" {
    count = "${length(data.aws_availability_zones.azs.names)}"
    vpc_id     = "${var.vpc-id}"
    cidr_block = "${var.egress-subnet-prefix}.${count.index+30+1}.0/24"
    availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
    tags = {
        Name = "egress-subnet-${count.index+1}"
        Tier = "Egress"
        Environment = "${var.env_name}"
    }
}


resource "aws_subnet" "data-subnet" {
    count = "${length(data.aws_availability_zones.azs.names)}"
    vpc_id     = "${var.vpc-id}"
    cidr_block = "${var.data-subnet-prefix}.${count.index+40+1}.0/24"
    availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
    tags = {
        Name = "data-subnet-${count.index+1}"
        Tier = "Data"
        Environment = "${var.env_name}"
    }
}

#################################################################
# Route table resources. 
# Ingress and Egress are attached to igw.
# Private subnets are attached to nat-gatewat
#################################################################

resource "aws_route_table" "ingress_rtb" {
  vpc_id  = "${var.vpc-id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags  = {
    Environment = "${var.env_name}"
    Name = "Ingress-RouteTable"
  }
}

resource "aws_route_table" "egress_rtb" {
  vpc_id  = "${var.vpc-id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags  = {
    Environment = "${var.env_name}"
    Name = "Egress-RouteTable"
  }
}

# resource "aws_route_table" "private_rtb" {
#   vpc_id  = "${var.vpc-id}"

#   route {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = "${aws_internet_gateway.igw.id}"
#   }

#   tags  = {
#     Environment = "${var.env_name}"
#     Name = "Private-RouteTable"
#   }
# }

resource "aws_route_table" "private_rtb" {
  count = "${length(aws_subnet.private-subnet.*.id)}"

  vpc_id  = "${var.vpc-id}"


  tags = {
    "Name" = "private_rtb-${count.index+1}"
  }
  
}

resource "aws_route" "private_nat_gateway" {
  count = "${length(aws_subnet.private-subnet.*.id)}"

  route_table_id         = element(aws_route_table.private_rtb.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat-gw.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "associate_private" {
  count = "${length(aws_subnet.private-subnet.*.id)}"

  subnet_id = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_rtb.*.id,count.index)
}


resource "aws_route_table" "data_rtb" {
  vpc_id  = "${var.vpc-id}"

  tags  = {
    Environment = "${var.env_name}"
    Name = "Data-RouteTable"
  }
}


resource "aws_route_table_association" "Assoiate_ingress" {
  count = "${length(aws_subnet.ingress-subnet.*.id)}"
  subnet_id     = "${element(aws_subnet.ingress-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.ingress_rtb.id}"
}

resource "aws_route_table_association" "Assoiate_egress" {
 count = "${length(aws_subnet.egress-subnet.*.id)}"
  subnet_id     = "${element(aws_subnet.egress-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.egress_rtb.id}"
}

resource "aws_route_table_association" "Assoiate_data" {
  count = "${length(aws_subnet.data-subnet.*.id)}"
  subnet_id     = "${element(aws_subnet.data-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.data_rtb.id}"
}

########################################################
# Nat gateway
# Associated to each egress subnet
# Elactic IPs are allocated to each nat-gateways
#########################################################

resource "aws_eip" "eip_nat" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  vpc = true

  tags  = {
    Environment = "${var.env_name}"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count = "${length(aws_subnet.egress-subnet.*.id)}"
  allocation_id = "${element(aws_eip.eip_nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.egress-subnet.*.id, count.index)}"

  tags = {
    Name = "Nat gateway"
  }

  depends_on = ["aws_internet_gateway.igw", "aws_eip.eip_nat"]
}

########################################################
# Network ACL
# 
# 
#########################################################

resource "aws_network_acl" "network_acl1" {
  vpc_id = "${var.vpc-id}"
  subnet_ids = concat("${aws_subnet.private-subnet.*.id}", "${aws_subnet.data-subnet.*.id}", "${aws_subnet.ingress-subnet.*.id}")

  tags = {
    Name = "network_acl-1"
  }
}

resource "aws_network_acl" "network_acl2" {
  vpc_id = "${var.vpc-id}"
  subnet_ids = "${aws_subnet.egress-subnet.*.id}"

  tags = {
    Name = "network_acl-2"
  }
}


resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.network_acl1.id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = var.public_inbound_acl_rules[count.index]["cidr_block"]
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)

  network_acl_id = aws_network_acl.network_acl1.id

  egress      = true
  rule_number = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = var.public_outbound_acl_rules[count.index]["cidr_block"]
}

resource "aws_network_acl_rule" "egress_inbound" {
  count = length(var.egress_inbound_acl_rules)

  network_acl_id = aws_network_acl.network_acl2.id

  egress      = false
  rule_number = var.egress_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.egress_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.egress_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.egress_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.egress_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.egress_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.egress_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = var.egress_inbound_acl_rules[count.index]["cidr_block"]
}

resource "aws_network_acl_rule" "egress_outbound" {
  count = length(var.egress_outbound_acl_rules)

  network_acl_id = aws_network_acl.network_acl2.id

  egress      = true
  rule_number = var.egress_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.egress_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.egress_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.egress_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.egress_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.egress_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.egress_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = var.egress_outbound_acl_rules[count.index]["cidr_block"]
}

###########################################################
# Security Group
#
###########################################################

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow traffic to ALB"
  vpc_id     = "${var.vpc-id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags  = {
    Environment = "${var.env_name}"
  }
}

resource "aws_security_group" "application_sg" {
  name        = "application-sg"
  description = "Allow traffic to Application"
  vpc_id     = "${var.vpc-id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags  = {
    Environment = "${var.env_name}"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow traffic to Bastion host"
  vpc_id     = "${var.vpc-id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags  = {
    Environment = "${var.env_name}"
  }
}

# resource "aws_security_group_rule" "alb_ingress_rules" {
#   count = "length(var.ingress_rules)

#   security_group_id = "${aws_security_group.alb_sg.id}"
#   type              = "ingress"

#   cidr_blocks      = ["${var.ingress_cidr_blocks}"]
#   ipv6_cidr_blocks = ["${var.ingress_ipv6_cidr_blocks}"]
#   prefix_list_ids  = ["${var.ingress_prefix_list_ids}"]

#   from_port   = "${element(var.rules[var.ingress_rules[count.index]], 0)}"
#   to_port     = "${element(var.rules[var.ingress_rules[count.index]], 1)}"
#   protocol    = "${element(var.rules[var.ingress_rules[count.index]], 2)}"

# }

# resource "aws_security_group_rule" "alb_egress_rules" {
#   count = "length(var.egress_rules)

#   security_group_id = "${aws_security_group.alb_sg.id}"
#   type              = "egress"

#   cidr_blocks      = ["${var.egress_cidr_blocks}"]
#   ipv6_cidr_blocks = ["${var.egress_ipv6_cidr_blocks}"]
#   prefix_list_ids  = ["${var.egress_prefix_list_ids}"]

#   from_port   = "${element(var.rules[var.egress_rules[count.index]], 0)}"
#   to_port     = "${element(var.rules[var.egress_rules[count.index]], 1)}"
#   protocol    = "${element(var.rules[var.egress_rules[count.index]], 2)}"

# }


###########################################################
#Outputs and DataSources
#
###########################################################



output "vpc_id" {
  
    value = "${aws_vpc.vpc-demo.id}"

}

output "private_subs" {
  value = ["${aws_subnet.private-subnet.*.id}"]
}

output "ingress_subs" {
  value = ["${aws_subnet.ingress-subnet.*.id}"]
}

output "alb_sg" {
  value = ["${aws_security_group.alb_sg.*.id}"]
}

output "app_sg" {
  value = ["${aws_security_group.application_sg.*.id}"]
}

output "bastion_sg" {
  value = ["${aws_security_group.bastion_sg.*.id}"]
}

