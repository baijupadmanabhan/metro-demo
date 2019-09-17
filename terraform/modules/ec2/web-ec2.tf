resource "aws_instance" "web" {
  ami           = "${var.ami-id}"
  instance_type = "${var.instance-type}"
  #subnet_id     = "${var.subnet-id}"
  

  tags = {
    Name = "HelloWorld"
    Environment = "${var.env_name}"
  }
}

