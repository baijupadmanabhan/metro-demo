###########################################################
#Outputs 
#
###########################################################
output "alb_dns_name" {  
    value = "${aws_alb.demo_alb.dns_name}"
}

output "bastion_eip" {  
    value = "${aws_eip.bastion_eip.public_ip}"
}