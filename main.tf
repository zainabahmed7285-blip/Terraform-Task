terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# VPC and Networking
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 3 Subnets across available AZs
resource "aws_subnet" "subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow inbound SSH and HTTP traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-web-sg"
  }
}

# -----------------------------------------------------------------------------
# EC2 Instances (5 instances distributed across the 3 subnets)
# -----------------------------------------------------------------------------
resource "aws_instance" "app_servers" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnets[count.index % length(aws_subnet.subnets)].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "app-server-${count.index + 1}"
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket
# -----------------------------------------------------------------------------
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "Application Storage"
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

