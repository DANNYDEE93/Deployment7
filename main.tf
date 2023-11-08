# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}
#
#
#
#
#create first instance:default-vpc with jenkins and deadsnakes
resource "aws_instance" "Dep7JenkinsManager" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-08d4347ac732ab2a4"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins-deadsnakes.sh")}"

  tags = {
    Name : "Dep7JenkinsManager"
  }
}
#
#
#
#
#create second instance:default-vpc with docker, java environment, and deadsnakes
resource "aws_instance" "Dep7DockerAgent" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-08d4347ac732ab2a4"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("docker-deadsnakes.sh")}"

  tags = {
    Name : "Dep7DockerAgent"
  }
}
#
#
#
#create third instance:default-vpc with terraform and java environment
resource "aws_instance" "D7TerraformAgent" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-08d4347ac732ab2a4"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("terraform-java.sh")}"

  tags = {
    Name : "D7TerraformAgent"
  }
}



output "dep7server1_ip" {
  value = aws_instance.Dep7JenkinsManager.public_ip
}

output "dep7server2_ip" {
  value = aws_instance.Dep7DockerAgent.public_ip
}

output "dep7server3_ip" {
  value = aws_instance.D7TerraformAgent.public_ip
}



