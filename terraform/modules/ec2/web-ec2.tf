# resource "aws_instance" "web" {
#   ami           = "${var.ami-id}"
#   instance_type = "${var.instance-type}"
#   #subnet_id     = "${var.subnet-id}"
  

#   tags = {
#     Name = "HelloWorld"
#     Environment = "${var.env_name}"
#   }
# }

resource "aws_iam_instance_profile" "demo_profile" {
    name = "demo_ec2_profile"
    role = "${aws_iam_role.demo_ec2_role.name}"
}

resource "aws_iam_role" "demo_ec2_role" {
    name = "demo_ec2_role"
    path = "/"

    assume_role_policy =<<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Principal": {
                "Service": "ec2.amazonaws.com"
              },
              "Effect": "Allow",
              "Sid": ""
          }
      ]
    }
EOF
}

resource "aws_launch_configuration" "demo_lc" {

    name_prefix                 = "demo_lc-"
    image_id                    = var.image_id
    instance_type               = var.instance_type
    iam_instance_profile        = "${aws_iam_instance_profile.demo_profile.name}"
    key_name                    = var.key_name
    security_groups             = var.app_sg_ids
    user_data                   = "${base64encode(file("${path.module}/install-nginx.sh"))}"
    #enable_monitoring           = var.enable_monitoring


    lifecycle {
      create_before_destroy = true
    }
}


resource "aws_autoscaling_group" "demo_asg" {

  name_prefix = "demo-app-"
  launch_configuration = "${aws_launch_configuration.demo_lc.name}"
  vpc_zone_identifier  = "${var.private_subnet_ids}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  target_group_arns         = ["${aws_alb_target_group.alb_target.id}"]
  default_cooldown          = "${var.default_cooldown}"
  #force_delete              = var.force_delete
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  # tags = {
  #     Name = "HelloWorld"
  #     Environment = "${var.env_name}"
  # }

lifecycle {
    create_before_destroy = true
  }
}

########################################################
# Application Loadbalancer configurations
#
#########################################################

resource "aws_alb_target_group" "alb_target" {
  name     = "${var.alb_target_grp_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"
}

resource "aws_alb" "demo_alb" {
  name            = "${var.alb_name}"
  subnets         = "${var.ingress_subnet_ids}"
  security_groups = "${var.alb_sg_ids}"
}



resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.demo_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target.id}"
    type             = "forward"
  }
}