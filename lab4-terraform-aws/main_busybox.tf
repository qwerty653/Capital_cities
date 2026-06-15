# Лабораторна робота 4: Terraform з BusyBox

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "web_sg" {
  name        = "web_server_sg_busybox"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbbfafef0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World from BusyBox" > index.html
    nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = "Terraform-BusyBox-Instance"
  }
}

output "busybox_instance_public_ip" {
  value = aws_instance.web.public_ip
}
