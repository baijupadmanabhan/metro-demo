#!/bin/bash
REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s | sed 's/[a-z]$//')
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${aws_eip.bastion_eip.id} --allow-reassociation --region ${REGION}
aws ec2 create-tags --resources $(curl http://169.254.169.254/latest/meta-data/instance-id) --tags Key=Name,Value=Bastion --region ${REGION}