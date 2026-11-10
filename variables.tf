variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name used in tags"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for the 3 subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Total number of EC2 instances to provision"
  type        = number
  default     = 5
}

variable "s3_bucket_prefix" {
  description = "Prefix for the primary S3 bucket name"
  type        = string
  default     = "my-terraform-app-bucket"
}

variable "s3_backup_bucket_prefix" {
  description = "Prefix for the secondary (backup/logs) S3 bucket name"
  type        = string
  default     = "my-terraform-backup-bucket"
}
