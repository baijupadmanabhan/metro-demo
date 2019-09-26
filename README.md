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

Diagram:

![alt text](https://github.com/baijupadmanabhan/metro-demo/blob/master/Demo-app-architecture.png)
 
 
|S.No | AWS Resources  | Description |
|-----| ------------- | ------------- |
|  1.  | VPC  | one AWS VPC   |
|  2.  | 1 Internet GW | Internet GateWay  |
|  3.  | Subnets  | Dyamic, based on number of AZs in the region For eg., if it in us-west-2 it will create 4 Private subnets, 4 Ingress Subnets, 4 Egress Subnets and 4 Data Subnets |
|  4.  | Natgateways | Dyamic, based on number of AZs. Any request to internet from private subnets will be routed to natgateway in same AZ  |
|  5.  | Route Tables  | Route tables created for each subnet types, private subnets talks to internet using netgateway route |
|  6.  | NACL   |  Network access control lists to allow only specific ports like 80, 443, 53, 22, 123 and ephemeral |
|  7.  | Bastion  | One bastion host to access Private instances which is in autoscale group |
|  8.  | ASG  | Random Password Generator Application is deployed in autoscaling group.
|  9.  | Security groups  | Security groups are created for bastion, ALB and appliction server.




# Usage

#### Install Terraform 0.14
#### Configure AWS Access Keys and Secret Keys (aws configure or ENV Variables)
#### Create ssh key in AWS account and provide it as value for the key 'key_name' in main.tf
#### Select amazon linux image for the region and pass it to 'image_id' in main.tf


```shell
  git clone https://github.com/baijupadmanabhan/metro-demo.git
  cd metro-demo/terraform/preprod
  terraform init
  terraform plan
  terraform apply
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


# What's Next !!!!!

* Creating a json file to load variables using lookup functions - will be usefull in creating multiple stacks with different variables such as instance type (dev,qa,prod, etc..)
* Implement conditional statements for some resources using "count"
* Write Readme for Modules
* Implement an option for s3 backed state management, we can default to local.

