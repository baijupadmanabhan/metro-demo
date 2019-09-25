#!/bin/bash
yum update -y
yum install git  -y
sudo yum install python
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
sudo cp ~/.local/bin/pip /usr/bin/
pip install pip --upgrade
pip install awsebcli --upgrade --user
source ~/.bashrc
pip install boto
pip install --upgrade ansible
git clone https://github.com/baijupadmanabhan/metro-demo.git
cd metro-demo/ansible/
ansible-playbook playbook.yml
REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s | sed 's/[a-z]$//')
aws ec2 create-tags --resources $(curl http://169.254.169.254/latest/meta-data/instance-id) --tags Key=Name,Value=Bastion --region ${REGION}
