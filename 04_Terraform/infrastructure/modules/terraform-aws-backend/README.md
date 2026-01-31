# Backend Module

This module creates and manages the Terraform backend infrastructure including:

- S3 bucket for state storage with versioning and encryption
- DynamoDB table for state locking
- IAM policies for backend access (optional)
- CloudWatch monitoring (optional)

## Features

- **S3 State Storage**: Secure, versioned storage for Terraform state files
- **State Locking**: DynamoDB table prevents concurrent modifications
- **Security**: Encryption at rest, public access blocked
- **Lifecycle Management**: Automatic cleanup of old state versions
- **Monitoring**: Optional CloudWatch logging
- **IAM Integration**: Optional IAM policy for backend access

## Usage

```hcl
module "backend" {
  source = "../../modules/backend"

  naming_prefix                = "myproject-dev"
  environment                  = "dev"
  aws_region                   = "ap-southeast-1"
  state_retention_days         = 30
  enable_point_in_time_recovery = true
  create_backend_policy        = true
  enable_monitoring            = true
  log_retention_days           = 30

  tags = {
    Project     = "MyProject"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Backend Configuration

After deploying this module, update your `backend.hcl` file with the output values:

```hcl
# Use the backend_config_hcl output
bucket         = "myproject-dev-terraform-state-abcd1234"
key            = "environments/dev/terraform.tfstate"
region         = "ap-southeast-1"
encrypt        = true
dynamodb_table = "myproject-dev-terraform-locks"
```

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 1.14.0 |
| aws       | ~> 6.30.0 |
| random    | ~> 3.0    |

## Providers

| Name   | Version   |
| ------ | --------- |
| aws    | ~> 6.30.0 |
| random | ~> 3.0    |

## Inputs

| Name                          | Description                                      | Type          | Default            | Required |
| ----------------------------- | ------------------------------------------------ | ------------- | ------------------ | :------: |
| naming_prefix                 | Prefix for naming resources                      | `string`      | n/a                |   yes    |
| environment                   | Environment name (dev, staging, prod)            | `string`      | n/a                |   yes    |
| aws_region                    | AWS region for resources                         | `string`      | `"ap-southeast-1"` |    no    |
| tags                          | Common tags to apply to all resources            | `map(string)` | `{}`               |    no    |
| state_retention_days          | Number of days to retain old state file versions | `number`      | `30`               |    no    |
| enable_point_in_time_recovery | Enable point in time recovery for DynamoDB table | `bool`        | `true`             |    no    |
| create_backend_policy         | Whether to create IAM policy for backend access  | `bool`        | `false`            |    no    |
| enable_monitoring             | Enable CloudWatch monitoring for backend         | `bool`        | `false`            |    no    |
| log_retention_days            | Number of days to retain CloudWatch logs         | `number`      | `30`               |    no    |

## Outputs

| Name                | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| s3_bucket_name      | Name of the S3 bucket for Terraform state                       |
| s3_bucket_arn       | ARN of the S3 bucket for Terraform state                        |
| s3_bucket_region    | Region of the S3 bucket for Terraform state                     |
| dynamodb_table_name | Name of the DynamoDB table for state locking                    |
| dynamodb_table_arn  | ARN of the DynamoDB table for state locking                     |
| backend_policy_arn  | ARN of the IAM policy for backend access                        |
| backend_config      | Backend configuration for use in other Terraform configurations |
| backend_config_hcl  | Backend configuration in HCL format for backend.hcl file        |

## Security Features

- **Encryption**: S3 bucket uses AES256 encryption
- **Versioning**: Enabled to track state changes
- **Public Access**: Completely blocked
- **DynamoDB Encryption**: Server-side encryption enabled
- **Point-in-Time Recovery**: Optional for DynamoDB table

## Cost Optimization

- **S3 Lifecycle**: Automatic cleanup of old versions
- **DynamoDB**: Pay-per-request billing mode
- **Monitoring**: Optional CloudWatch logs to control costs
