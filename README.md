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
|  2.  | 1 Internet GW | Internet GateWay  |
|  3.  | Subnets  | Dyamic, based on number of AZs in the region For eg., if it in us-west-2 it will create 4 Private subnets, 4 Ingress Subnets, 4 Egress Subnets and 4 Data Subnets |
|  4.  | Natgateways | Dyamic, based on number of AZs. Any request to internet from private subnets will be routed to natgateway in same AZ  |
|  5.  | Route Tables  | Private Route tables Per region associated with respective NAT GateWays |
|  6.  | NACL   |  Network access control lists to deny all inbound except 80,443 |
|  7.  | Bastion  | One bastion host to access Private instances |
|  8.  | 1 ASG  | Random Password Generator Application is deployed in this autoscaling group.
|  9.  | Security groups  | Security groups are created for bastion, ALB and appliction server.




# Usage

#### Install Terraform 0.14
#### Configure AWS Access Keys and Secret Keys (aws configure or ENV Variables)
#### Create ssh key in AWS account and provide is as value for the key 'key_name' in main.tf
#### Select amazon linux image for the region and pass it to 'image_id' in main.tf


```shell
  git clone https://github.com/baijupadmanabhan/metro-demo.git
  cd metro-demo/terraform/preprod
  terraform init
  terraform plan
  terraform apply --yes 
  ```

Note: Infrastructure can be created in any region just by passing region name, ssh key name and ami-id.

# Ansible 

I have used simple ansible playbook in user data to install the application. 

This playbook installs nginx, Golang and downloads the UI files and starts the application.


Note: <i> This can be done in multiple other ways depending on the use case.



# Random Password Generator

Golang is used to create password generator api. Math Rand seeding current time is used to generate random string from a given character set.

Simple jQuery ajax function is used to call the api with an input parameter so that the api will return random password in that given length.

Request from ALB will be landing in nginx to serve the html pages. Api calls with a context root of \/app will be passed to application listening on 8080.





