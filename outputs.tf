output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.subnets[*].id
}

output "ec2_instance_ids" {
  description = "IDs of the 5 EC2 instances"
  value       = aws_instance.app_servers[*].id
}

output "ec2_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.app_servers[*].public_ip
}

output "ec2_web_urls" {
  description = "HTTP URLs to test web servers on EC2 instances"
  value       = [for ip in aws_instance.app_servers[*].public_ip : "http://${ip}"]
}

output "ssh_commands" {
  description = "SSH connection commands for each EC2 instance"
  value       = [for ip in aws_instance.app_servers[*].public_ip : "ssh -i ec2_key.pem ec2-user@${ip}"]
}

output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.app_bucket.arn
}
