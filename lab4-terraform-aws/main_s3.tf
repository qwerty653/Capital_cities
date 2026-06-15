# Лабораторна робота 4: Terraform з S3 статичним хостингом

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-lab-bucket-1781463587"
  acl    = "private"
}

resource "aws_s3_bucket_object" "index_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "./index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
