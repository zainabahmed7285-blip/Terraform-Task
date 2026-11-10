<#
.SYNOPSIS
    Helper script to initialize Git, commit all Terraform files, and push to GitHub.
#>
param (
    [Parameter(Mandatory = $false)]
    [string]$RepoUrl
)

Write-Host "=== Preparing Terraform Project for GitHub ===" -ForegroundColor Cyan

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH. Please install Git first."
    exit 1
}

# Initialize git if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "[1/4] Initializing Git repository..." -ForegroundColor Yellow
    git init
} else {
    Write-Host "[1/4] Git repository already initialized." -ForegroundColor Green
}

# Add all files
Write-Host "[2/4] Staging files (excluding secrets via .gitignore)..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "[3/4] Committing files..." -ForegroundColor Yellow
git commit -m "Provision 5 EC2, 1 VPC, 3 Subnets, 2 S3 Buckets with full tagging"

# Push if RepoUrl provided
if ($RepoUrl) {
    Write-Host "[4/4] Setting remote origin and pushing to $RepoUrl..." -ForegroundColor Yellow
    git branch -M main
    git remote remove origin 2>$null
    git remote add origin $RepoUrl
    git push -u origin main
    Write-Host "Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "`nTo push to your GitHub repo, run:" -ForegroundColor Cyan
    Write-Host "  git branch -M main"
    Write-Host "  git remote add origin https://github.com/<YOUR-USERNAME>/<YOUR-REPO-NAME>.git"
    Write-Host "  git push -u origin main"
}

