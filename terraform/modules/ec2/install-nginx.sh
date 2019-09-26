#!/bin/bash
yum update -y
yum install git  -y
sudo yum install python
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
sudo cp ~/.local/bin/pip /usr/bin/
pip install pip --upgrade
pip install awsebcli --upgrade --user
#source ~/.bashrc
pip install boto
pip install --upgrade ansible
git clone https://github.com/baijupadmanabhan/metro-demo.git
cd metro-demo/ansible/
ansible-playbook playbook.yml

cd /usr/local/
sudo wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
tar -xzf go1.13.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bash_profile
source /root/.bash_profile
mkdir ~/go-workspace
cp /metro-demo/Golang/main.go ~/go-workspace/
cp /metro-demo/Golang/main ~/go-workspace/
export GOROOT=/usr/local/go
export GOPATH=~/go-workspace
export GOBIN="$GOPATH/bin"
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
 
go get -v -u github.com/gorilla/mux &&
# cd /root/go-workspace; go install main.go
nohup /metro-demo/Golang/main >/dev/null 2>&1 &
REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s | sed 's/[a-z]$//')
aws ec2 create-tags --resources $(curl http://169.254.169.254/latest/meta-data/instance-id) --tags Key=Name,Value=Webserver --region ${REGION}
