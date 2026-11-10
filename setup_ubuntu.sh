#!/usr/bin/env bash
# =============================================================================
# Automated Setup Script for Ubuntu EC2 Instances
# Installs Git, AWS CLI v2, and Terraform, and sets up project workspace
# =============================================================================

set -e

echo "=== [1/4] Updating package index and installing essentials ==="
sudo apt-get update -y
sudo apt-get install -y curl wget unzip gnupg software-properties-common git

echo "=== [2/4] Installing official HashiCorp Terraform ==="
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform

echo "=== [3/4] Installing AWS CLI v2 ==="
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

echo "=== [4/4] Verifying installations ==="
echo "Git version:       $(git --version)"
echo "Terraform version: $(terraform -version | head -n 1)"
echo "AWS CLI version:   $(aws --version)"

echo ""
echo "================================================================="
echo "Setup completed successfully!"
echo "To clone your repository, run:"
echo "  git clone <YOUR-GITHUB-REPO-URL>"
echo "  cd <YOUR-REPO-FOLDER>"
echo "  terraform init"
echo "  terraform plan"
echo "================================================================="

