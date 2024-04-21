terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"  
  access_key = "AKIAQ3EGWLWKCEOXRHRJ"
  secret_key = "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"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  
  enable_dns_support = true
  enable_dns_hostnames = true
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a subnet inside the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"  # Update with your desired subnet CIDR block
  availability_zone = "ap-south-1a"  # Update with your desired AZ
  map_public_ip_on_launch = true
}

# Create a route table and associate it with the VPC
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create an EC2 instance
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-001843b876406202a"  # Update with your desired AMI ID (Amazon Linux 2 as an example)
  instance_type = "t2.micro"  # Update with your desired instance type

  subnet_id = aws_subnet.my_subnet.id

  tags = {
    Name = "MyEC2Instance"
  }

  # Provision the EC2 instance using user data
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF
}
