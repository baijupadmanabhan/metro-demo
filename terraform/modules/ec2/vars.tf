variable "vpc-id" {}

variable "env_name" {}

#variable "subnet-id" {
#    type    = list(string)    
#}

# Launch configuration
variable "image_id" {
  description = "The EC2 image ID to launch"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type to launch"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to ec2 instance"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key name to attach to instance"
  type        = string
  default     = ""
}

variable "health_check_type" {
  description = "Health check thype EC2 and ELB"
  type        = string
}

variable "health_check_grace_period" {
  description = "Grace period for instance health check"
  type        = number
  default     = 180
}

variable "security_groups" {
  description = "Security group list"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "Userdata to bootsratp instance"
  type        = string
  default     = " "
}

# Autoscaling group
variable "max_size" {
  description = "Auto scale group max size"
  type        = string
}

variable "min_size" {
  description = "Auto scale group min size"
  type        = string
}

variable "desired_capacity" {
  description = "Auto scale group desired size"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ingress_subnet_ids" {
  description = "List of private Ingress IDs"
  type        = list(string)
}

variable "alb_sg_ids" {
  description = "ALB security group IDs"
  type        = list(string)
}

variable "app_sg_ids" {
  description = "Application security group IDs"
  type        = list(string)
}

variable "bastion_sg_ids" {
  description = "Bation security group IDs"
  type        = list(string)
}

variable "default_cooldown" {
  description = "Grace period in between scaling activities"
  type        = number
  default     = 300
}

variable "wait_for_capacity_timeout" {
  description = "Terraform timeout to wait to launch ASG"
  type        = string
  default     = "10m"
}

variable "min_elb_capacity" {
  description = "Min number of instance to show up"
  type        = number
  default     = 0
}

variable "wait_for_elb_capacity" {
  description = "Min number of healthy instances attached to ALB"
  type        = number
  default     = null
}

variable "alb_target_grp_name" {
  description = "The name of the target group"
  type        = string
}

variable "alb_name" {
  description = "The name of Application load balancer"
  type        = string
}