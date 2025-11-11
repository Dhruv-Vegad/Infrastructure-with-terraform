terraform {
  required_providers{
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}   

provider "aws" {
    region = "ap-south-1"
}


resource "aws_security_group" "allow_ssh"{
    name = "allow_ssh"
    ingress {
        from_port = 80
        to_port  = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { 
        from_port = 0
        to_port= 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "ec2-instance" {
  ami = "ami-02b8269d5e85954ef"
  instance_type = "t2.micro"

    security_groups = [aws_security_group.allow_ssh.name]

    tags = {
        Name = "terraform-nginx-server"
    }

    user_data = <<-EOF
    #!/bin/bash
    sudo apt-update 
    sudo apt-install nginx -y
    systemctl start nginx
    systemctl enable nginx
    EOF
}