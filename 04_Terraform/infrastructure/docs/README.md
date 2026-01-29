# Enterprise Terraform Project

## Overview

This is an enterprise-grade Terraform project following best practices for infrastructure as code (IaC). The project is structured to support multiple environments with reusable modules and consistent patterns.

## Architecture

### Project Structure

```
infrastructure/
├── environments/          # Environment-specific configurations
│   ├── dev/              # Development environment
│   ├── staging/          # Staging environment (to be created)
│   └── prod/             # Production environment
├── modules/              # Reusable Terraform modules
│   ├── networking/       # VPC, subnets, gateways
│   ├── compute/          # EC2, ASG, launch templates
│   ├── security/         # Security groups
│   └── storage/          # S3, EBS (to be added)
├── shared/               # Shared configurations
│   ├── data-sources/     # Common data sources
│   └── locals/           # Local values
├── scripts/              # Automation scripts
└── docs/                 # Documentation
```

## Features

### Infrastructure Components

- **VPC with Public/Private Subnets**: Multi-AZ setup with proper CIDR allocation
- **NAT Gateways**: For private subnet internet access (configurable)
- **Security Groups**: Layered security with minimal required access
- **Auto Scaling Groups**: Horizontal scaling capability
- **Launch Templates**: Standardized instance configuration
- **CloudWatch Integration**: Monitoring and logging

### Best Practices Implemented

1. **Modular Design**: Reusable modules for different components
2. **Environment Separation**: Isolated configurations per environment
3. **State Management**: Remote state with S3 backend and DynamoDB locking
4. **Tagging Strategy**: Consistent tagging across all resources
5. **Security**: Encrypted volumes, restrictive security groups
6. **Documentation**: Comprehensive README and inline comments

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Appropriate AWS permissions

### Setup Steps

1. **Clone and Navigate**

   ```bash
   cd infrastructure/environments/dev
   ```

2. **Configure Backend** (Optional but recommended)

   ```bash
   # Edit backend.hcl with your S3 bucket details
   terraform init -backend-config="backend.hcl"
   ```

3. **Review Variables**

   ```bash
   # Edit terraform.tfvars to match your requirements
   nano terraform.tfvars
   ```

4. **Deploy Infrastructure**

   ```bash
   # Using the deployment script (recommended)
   ../../../scripts/deploy.sh dev plan
   ../../../scripts/deploy.sh dev apply

   # Or using terraform directly
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

## Module Documentation

### Networking Module

- Creates VPC with DNS support
- Public and private subnets across multiple AZs
- Internet Gateway and NAT Gateways
- Route tables and associations

**Inputs:**

- `vpc_cidr`: VPC CIDR block
- `public_subnet_cidrs`: List of public subnet CIDRs
- `private_subnet_cidrs`: List of private subnet CIDRs
- `enable_nat_gateway`: Enable NAT gateways

**Outputs:**

- `vpc_id`: VPC identifier
- `public_subnet_ids`: Public subnet identifiers
- `private_subnet_ids`: Private subnet identifiers

### Security Module

- Web server security group (HTTP/HTTPS access)
- Database security group (restricted to web servers)
- ALB security group for load balancers
- SSH access (configurable)

**Inputs:**

- `vpc_id`: VPC where security groups are created
- `allowed_cidr_blocks`: CIDRs allowed web access
- `enable_ssh_access`: Enable SSH access
- `ssh_cidr_blocks`: CIDRs allowed SSH access

### Compute Module

- Launch templates with best practices
- Auto Scaling Groups (optional)
- Single EC2 instances (fallback)
- EBS encryption and optimization
- CloudWatch monitoring

**Inputs:**

- `instance_type`: EC2 instance type
- `enable_auto_scaling`: Use ASG or single instances
- `min_size`, `max_size`, `desired_capacity`: ASG sizing

## Environment Configurations

### Development Environment

- Smaller instance types (t3.micro)
- NAT Gateway disabled (cost optimization)
- Relaxed security for development access
- Single instance deployment

### Production Environment

- Production-grade instances (t3.small+)
- NAT Gateways enabled
- Restrictive security groups
- Auto Scaling enabled
- Enhanced monitoring

## Security Considerations

### Implemented Security Measures

1. **Network Isolation**: Private subnets for sensitive workloads
2. **Security Groups**: Principle of least privilege
3. **Encryption**: EBS volumes encrypted at rest
4. **Instance Metadata**: IMDSv2 enforced
5. **Tagging**: Resource tracking and access control

### Recommendations

1. Use AWS IAM roles instead of access keys
2. Implement AWS Config for compliance monitoring
3. Enable CloudTrail for audit logging
4. Use AWS Secrets Manager for sensitive data
5. Implement backup strategies

## Cost Optimization

### Implemented Optimizations

1. **Conditional Resources**: NAT Gateways optional in dev
2. **Right-sizing**: Appropriate instance types per environment
3. **EBS Optimization**: gp3 volumes for better cost/performance
4. **Tagging**: Cost allocation and tracking

### Additional Recommendations

1. Use Spot Instances for non-critical workloads
2. Implement lifecycle policies for logs and backups
3. Regular cost reviews and optimization
4. Use AWS Cost Explorer and Budgets

## Monitoring and Logging

### Built-in Monitoring

1. CloudWatch agent installation via user data
2. Instance-level monitoring
3. Resource tagging for organization

### Recommended Additions

1. Application-level monitoring (e.g., New Relic, Datadog)
2. Log aggregation (e.g., ELK stack, CloudWatch Logs)
3. Alerting for critical metrics
4. Performance monitoring

## Troubleshooting

### Common Issues

1. **Backend Configuration**

   ```bash
   # If state bucket doesn't exist
   terraform init  # Will create local state, migrate later
   ```

2. **Permission Issues**

   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   ```

3. **Resource Conflicts**

   ```bash
   # Import existing resources
   terraform import aws_vpc.main vpc-xxxxxxxxx
   ```

4. **State Corruption**
   ```bash
   # Backup and recover state
   terraform state pull > backup.tfstate
   terraform state push backup.tfstate
   ```

## Contributing

### Development Workflow

1. Create feature branch
2. Make changes to modules or environments
3. Test in development environment
4. Update documentation
5. Submit pull request

### Code Standards

1. Use `terraform fmt` for formatting
2. Run `terraform validate` before commits
3. Follow naming conventions
4. Add comments for complex logic
5. Update documentation

## Support and Maintenance

### Regular Tasks

1. **Weekly**: Review cost reports and optimization opportunities
2. **Monthly**: Update Terraform providers and modules
3. **Quarterly**: Security review and compliance check
4. **Annually**: Architecture review and improvements

### Backup Strategy

1. **State Files**: Automated S3 versioning and cross-region replication
2. **Configuration**: Git repository with proper branching
3. **Infrastructure**: Regular AMI snapshots and data backups

## References

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Infrastructure as Code Patterns](https://infrastructure-as-code.com/patterns/)
