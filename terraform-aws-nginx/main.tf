terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


# Renamed to reflect its new purpose
resource "aws_security_group" "allow_http_ssh" {
  name_prefix = "nginx_sec_grp"

  # Rule for HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ⬇️ ADDED: Rule for SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2-instance" {
  ami           = "ami-02b8269d5e85954ef"
  instance_type = "t2.micro"

  # ⬇️ UPDATED: Use the new security group name
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  
  subnet_id = "subnet-01a456c8f9df7db15"
  associate_public_ip_address = true

  key_name = "ec2-demo"

  tags = {
    Name = "terraform-nginx-server"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
  EOF
}

# This will print the IP to make it easy to connect
output "public_ip" {
  value = aws_instance.ec2-instance.public_ip
}