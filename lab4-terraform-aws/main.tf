terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-2"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  default     = "anton-kurnakov-terraform-lab4-2026"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gnuefi"]
  }
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

resource "aws_instance" "web_apache" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              echo "<html><body><h1>Простий веб-сайт на EC2!</h1></body></html>" | tee /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Terraform-Apache-Instance"
  }
}

resource "aws_instance" "web_busybox" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > /home/ec2-user/index.html
              nohup busybox httpd -f -p 8080 -h /home/ec2-user &
              EOF

  tags = {
    Name = "TerraformInstanceBusyBox"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

output "apache_url" {
  value = "http://${aws_instance.web_apache.public_ip}"
}

output "busybox_url" {
  value = "http://${aws_instance.web_busybox.public_ip}:8080"
}

output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
