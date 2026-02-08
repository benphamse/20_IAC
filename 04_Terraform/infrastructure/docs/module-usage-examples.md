# Module Usage Examples

## Sử dụng modules trong environment configuration

### 1. Basic Infrastructure Stack

```hcl
# Core infrastructure
module "networking" { ... }
module "security" { ... }
module "compute" { ... }
```

### 2. Full Application Stack

```hcl
# Core infrastructure
module "networking" { ... }
module "security" { ... }
module "compute" { ... }

# Application services
module "database" { ... }
module "storage" { ... }
module "load_balancing" { ... }
module "monitoring" { ... }
```

### 3. Microservices Architecture

```hcl
# Shared infrastructure
module "networking" { ... }
module "security" { ... }

# Service-specific modules
module "api_service" {
  source = "../../modules/compute"
  # Service-specific configurations
}

module "auth_service" {
  source = "../../modules/compute"
  # Service-specific configurations
}

module "user_service" {
  source = "../../modules/serverless"
  # Lambda-based service
}
```

### 4. Multi-Tier Application

```hcl
# Web tier
module "web_load_balancer" {
  source = "../../modules/load-balancing"
}

module "web_servers" {
  source = "../../modules/compute"
}

# Application tier
module "app_servers" {
  source = "../../modules/compute"
}

# Data tier
module "database" {
  source = "../../modules/database"
}

module "cache" {
  source = "../../modules/database"
  # Redis/ElastiCache configuration
}
```

## Module Naming Best Practices

### ✅ **Good Examples:**

- `networking` - VPC, subnets, gateways
- `security` - Security groups, NACLs, WAF
- `compute` - EC2, ASG, containers
- `database` - RDS, DynamoDB, caching
- `storage` - S3, EBS, EFS
- `load-balancing` - ALB, NLB, CloudFront
- `monitoring` - CloudWatch, logging
- `messaging` - SQS, SNS, EventBridge
- `serverless` - Lambda, API Gateway
- `cicd` - CodePipeline, CodeBuild

### ❌ **Avoid:**

- `aws-vpc` (redundant aws prefix)
- `ec2-instances` (too specific)
- `my-database` (unclear naming)
- `stuff` (meaningless)
- `utils` (too generic)

## Module Organization Patterns

### By Service Category

```
modules/
├── infrastructure/
│   ├── networking/
│   ├── security/
│   └── compute/
├── data/
│   ├── database/
│   ├── storage/
│   └── analytics/
└── application/
    ├── serverless/
    ├── container/
    └── messaging/
```

### By AWS Service

```
modules/
├── ec2/
├── rds/
├── s3/
├── lambda/
├── ecs/
└── api-gateway/
```

### Hybrid Approach (Recommended)

```
modules/
├── networking/      # VPC, subnets, etc.
├── security/        # Security groups, IAM
├── compute/         # EC2, ASG
├── database/        # RDS, DynamoDB
├── storage/         # S3, EFS
├── load-balancing/  # ALB, CloudFront
├── monitoring/      # CloudWatch
├── serverless/      # Lambda, API Gateway
└── container/       # ECS, EKS
```
