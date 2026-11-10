# Terraform AWS Infrastructure: 5 EC2, 1 VPC, 3 Subnets, 1 S3 Bucket

This repository provisions complete AWS infrastructure with high availability and secure best practices.

## Architecture Overview

- **1 VPC**: `10.0.0.0/16` with DNS hostname and resolution enabled.
- **3 Subnets**: `10.0.1.0/24`, `10.0.2.0/24`, and `10.0.3.0/24` deployed across distinct Availability Zones.
- **Internet Gateway & Route Tables**: Attached to the VPC with routing for public internet access.
- **Security Group**: Allows inbound ports `22` (SSH) and `80` (HTTP), and unrestricted outbound traffic.
- **5 EC2 Instances**:
  - Running latest Amazon Linux 2023.
  - Automatically distributed across the 3 subnets (`count.index % 3`).
  - Bootstrapped with an Apache HTTP server serving instance metadata and S3 reference.
  - Secured with an IAM role granting read/write access to the application S3 bucket.
- **SSH Key Pair**: Automatically generated 4096-bit RSA key saved locally as `ec2_key.pem`.
- **1 S3 Bucket**: 
  - Unique name generated with a random 4-byte hex suffix.
  - Public Access Block strictly enabled.
  - Server-side AES-256 encryption enabled by default.

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
- Web URLs: Click any URL (`http://<EC2_IP>`) to see the server test page.
- SSH Commands:
  ```bash
  ssh -i ec2_key.pem ec2-user@<EC2_PUBLIC_IP>
  ```
- S3 Bucket Name: Verified through IAM permissions from within the EC2 instances (`aws s3 ls s3://<BUCKET_NAME>`).

### 6. Cleanup
```bash
terraform destroy
```

