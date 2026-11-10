# Terraform AWS Infrastructure: 5 EC2, 1 VPC, 3 Subnets, 2 S3 Buckets

This repository provisions complete AWS infrastructure with high availability, security best practices, and standard tags.

## Architecture Overview

- **1 VPC**: `10.0.0.0/16` with DNS hostname and resolution enabled.
- **3 Subnets**: `10.0.1.0/24`, `10.0.2.0/24`, and `10.0.3.0/24` deployed across distinct Availability Zones.
- **Internet Gateway & Route Tables**: Attached to the VPC with routing for public internet access.
- **Security Group**: Allows inbound ports `22` (SSH) and `80` (HTTP), and unrestricted outbound traffic.
- **5 EC2 Instances**:
  - Running official Ubuntu 22.04 LTS (Canonical).
  - Round-robin distributed across the 3 subnets (`count.index % 3`).
  - Bootstrapped with an Apache HTTP server (`apache2`) showing instance details and both S3 bucket names.
  - IAM profile granting read/write access to both S3 buckets.
- **SSH Key Pair**: Automatically generated 4096-bit RSA key saved locally as `ec2_key.pem`.
- **2 S3 Buckets**:
  - `aws_s3_bucket.app_bucket`: Primary storage for application data.
  - `aws_s3_bucket.backup_bucket`: Secondary storage for backups and logs.
  - Both protected with default server-side AES-256 encryption and public access blocks.
- **Consistent Tagging**:
  - Provider-level `default_tags` (`Environment`, `Project`, `ManagedBy`).
  - Resource-specific tags (`Name`, `Role`, `Tier`, `Purpose`, `AZ`).

---

## Deployment Instructions

### 1. Prerequisites
Ensure you have the [Terraform CLI](https://developer.hashicorp.com/terraform/install) and [AWS CLI](https://aws.amazon.com/cli/) installed and configured:
```bash
aws configure
```

### 2. Initialize Providers
```bash
terraform init
```

### 3. Review Plan
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply -auto-approve
```

### 5. Accessing Your Instances
After deployment, Terraform outputs:
- Web URLs: Click any URL (`http://<EC2_IP>`) to see the server test page listing both S3 buckets.
- SSH Commands:
  ```bash
  ssh -i ec2_key.pem ubuntu@<EC2_PUBLIC_IP>
  ```
- S3 Bucket Names: Verified through IAM permissions directly from the EC2 instances (`aws s3 ls s3://<BUCKET_NAME>`).

### 6. Cleanup
```bash
terraform destroy
```
