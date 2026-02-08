# AWS Services Module Naming Convention

## Core Infrastructure Modules

├── networking/ # VPC, Subnets, Gateways, Route Tables
├── security/ # Security Groups, NACLs, WAF
├── compute/ # EC2, ASG, Launch Templates
├── storage/ # S3, EBS, EFS
├── database/ # RDS, DynamoDB, ElastiCache
├── load-balancing/ # ALB, NLB, CloudFront
├── monitoring/ # CloudWatch, X-Ray, Config
├── backup/ # AWS Backup, Snapshots

## Application Services Modules

├── container/ # ECS, EKS, Fargate
├── serverless/ # Lambda, API Gateway, Step Functions
├── messaging/ # SQS, SNS, EventBridge
├── data-processing/ # EMR, Glue, Kinesis, Redshift
├── ml-ai/ # SageMaker, Comprehend, Rekognition
├── analytics/ # Athena, QuickSight, OpenSearch

## Security & Compliance Modules

├── identity/ # IAM, Cognito, Directory Service
├── secrets/ # Secrets Manager, Parameter Store
├── encryption/ # KMS, CloudHSM, ACM
├── compliance/ # Config Rules, GuardDuty, Security Hub

## DevOps & Management Modules

├── cicd/ # CodePipeline, CodeBuild, CodeDeploy
├── infrastructure/ # CloudFormation, Service Catalog
├── cost-management/ # Budgets, Cost Explorer automation
├── governance/ # Organizations, Control Tower

## Network Services Modules

├── dns/ # Route53, Private Hosted Zones
├── cdn/ # CloudFront distributions
├── vpn/ # VPN Gateway, Direct Connect
├── network-security/ # WAF, Shield, Firewall Manager

## Shared/Common Modules

├── shared/
│ ├── data-sources/ # Common data sources
│ ├── locals/ # Reusable local values
│ ├── policies/ # Common IAM policies
│ └── tags/ # Tagging strategies
└── utils/
├── validation/ # Input validation rules
├── naming/ # Naming convention helpers
└── helpers/ # Utility functions
