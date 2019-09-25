###########################################################
#Outputs 
#
###########################################################
output "demo_alb_dns_name" {  
    value = "${module.web-ec2.alb_dns_name}"
}

output "demo_bastion_eip" {  
    value = "${module.web-ec2.bastion_eip}"
}
