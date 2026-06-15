# Лабораторна робота 4: Terraform з Apache

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "web_sg" {
  name        = "web_server_sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    sudo yum update -y
    sudo yum install -y httpd
    echo "<html><body><h1>Простий веб-сайт на EC2 з Apache!</h1></body></html>" | sudo tee /var/www/html/index.html
    sudo systemctl start httpd
    sudo systemctl enable httpd
  EOF

  tags = {
    Name = "Terraform-Apache-Instance"
  }
}

output "apache_instance_public_ip" {
  value = aws_instance.web.public_ip
}
