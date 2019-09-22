# resource "aws_instance" "web" {
#   ami           = "${var.ami-id}"
#   instance_type = "${var.instance-type}"
#   #subnet_id     = "${var.subnet-id}"
  

#   tags = {
#     Name = "HelloWorld"
#     Environment = "${var.env_name}"
#   }
# }

resource "aws_launch_configuration" "bastion_lc" {

    name_prefix                 = "bastion_lc-"
    image_id                    = var.image_id
    instance_type               = var.instance_type
    iam_instance_profile        = "${aws_iam_instance_profile.demo_profile.name}"
    key_name                    = var.key_name
    security_groups             = var.bastion_sg_ids
    #user_data                   = ""
    #enable_monitoring           = var.enable_monitoring


    lifecycle {
      create_before_destroy = true
    }
}


resource "aws_autoscaling_group" "bastion_asg" {

  name_prefix = "bastion-app-"
  launch_configuration = "${aws_launch_configuration.bastion_lc.name}"
  vpc_zone_identifier  = "${var.ingress_subnet_ids}"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  #min_elb_capacity          = "${var.min_elb_capacity}"
  #wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  #target_group_arns         = ["${aws_alb_target_group.alb_target.id}"]
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