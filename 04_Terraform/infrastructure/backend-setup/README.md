# Backend Setup Guide

This directory contains the configuration to set up Terraform backend infrastructure.

## Overview

The backend setup creates:

- S3 buckets for state storage (dev and prod)
- DynamoDB tables for state locking
- IAM policies for backend access
- CloudWatch monitoring (optional)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.14.0 installed

## Setup Process

### Step 1: Initialize Backend Infrastructure

```bash
cd backend-setup
terraform init
terraform plan
terraform apply
```

### Step 2: Update Environment Backend Configurations

After applying, copy the output configurations to your environment `backend.hcl` files:

**For Development:**

```bash
# Copy the dev_backend_config output to environments/dev/backend.hcl
```

**For Production:**

```bash
# Copy the prod_backend_config output to environments/prod/backend.hcl
```

### Step 3: Initialize Environments with Remote State

```bash
cd environments/dev
terraform init -backend-config=backend.hcl

cd ../prod
terraform init -backend-config=backend.hcl
```

### Step 4: Migrate Existing State (if any)

If you have existing local state files:

```bash
terraform init -migrate-state -backend-config=backend.hcl
```

## Directory Structure

```
backend-setup/
├── main.tf           # Main configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── terraform.tfvars  # Variable values
└── README.md         # This file
```

## Configuration

Edit `terraform.tfvars` to customize:

```hcl
project_name          = "your-project-name"
aws_region           = "us-east-1"
create_backend_policy = true
enable_monitoring     = false
```

## Security

- S3 buckets are encrypted with AES256
- Public access is completely blocked
- DynamoDB tables use server-side encryption
- IAM policies follow least privilege principle

## Cost Considerations

- S3 charges for storage and requests
- DynamoDB uses pay-per-request billing
- CloudWatch logs incur charges if enabled

## Troubleshooting

### Common Issues

1. **Bucket name conflicts**: S3 bucket names must be globally unique
2. **IAM permissions**: Ensure your AWS credentials have sufficient permissions
3. **Region availability**: Ensure all services are available in your chosen region

### Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*", "dynamodb:*", "iam:*", "cloudwatch:*"],
      "Resource": "*"
    }
  ]
}
```

## Cleanup

To destroy the backend infrastructure:

```bash
cd backend-setup
terraform destroy
```

⚠️ **Warning**: This will delete all state files and make them unrecoverable!
