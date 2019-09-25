###########################################################
#Outputs 
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