# Terraform with Ansible Demo Project

This project is created to demonstrate how to create a production grade AWS infrastructure
and deploy a Web application using ansible tasks. 

Project Scope:
* Terraform Modules are used
* Ansible is used to install and bootstrap the servers
* Parameterized
* Highly Available Infrastructure
* One click deploy
* Deploy to any region in AWS.


# AWS Infrastructure
|S.No | AWS Resources  | Description |
|-----| ------------- | ------------- |
|  1.  | VPC  | one AWS VPC   |
|  2.  | Subnets  | Dyamic, based on number of AZs in the region | For eg if it in in us-west-2 it will create 4 Private subnets, 4 Ingress Subnets, 4 Egress Subnets, 4 Data Subnets |
|  3.  | 1 Internet GW | Internet GateWay  |
|  4.  | Route Tables  | Private Route tables Per region associated with respective NAT GateWays |
|  5.  | NACL   |  Network access control lists to deny all inbound except 80,443 |
|  6.  | Bastion  | One bastion host to access Private instances |
|  7.  | 1 ASG  | Random Password Generator Application is deployed in this autoscaling group.




# Usage

#### Install Terraform 0.14
#### Configure AWS Access Keys and Secret Keys (aws configure or ENV Variables)


```shell
  git clone https://github.com/baijupadmanabhan/metro-demo.git
  cd metro-demo/terraform/preprod
  terraform init
  terraform plan
  terraform apply --yes 
  ```

# Ansible 

I have used simple ansible playbook in user data to install the application. 

This playbook installs nginx, Golang and downloads the UI files and starts the application.


Note: <i> This can be done in multiple other ways depending on the use case.



# Random Password Generator

Golang is used to create password generator api. Math Rand seeding current time is used to generate random string from a given character set.
Simple jQuery ajax function is used to call the api with a input parameter so that the api will return random password in that given length.
Request from ALB will be landing in nginx to server the html pages and api call with a context root \/app will be passed to application listening on 8080.





