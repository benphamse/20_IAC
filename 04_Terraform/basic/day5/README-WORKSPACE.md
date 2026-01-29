# Terraform Workspace + tfvars - Quản lý Môi trường Dev/Test/Prod

## 🎯 Tổng quan

Project này sử dụng **Terraform Workspace** kết hợp với **tfvars files** để quản lý 3 môi trường riêng biệt từ cùng một codebase:

- **dev**: Môi trường phát triển
- **test**: Môi trường kiểm thử
- **prod**: Môi trường sản xuất

## ✨ **Tại sao sử dụng tfvars? (Best Practice)**

1. **Tách biệt code và data** - Infrastructure logic vs configuration values
2. **Bảo mật tốt hơn** - Sensitive values không hard-code
3. **Dễ maintain** - Thay đổi config không cần sửa code
4. **Team collaboration** - Mỗi thành viên có thể có config riêng
5. **CI/CD friendly** - Inject values từ environment variables
6. **Validation** - Terraform validate config trước khi apply

## 📁 Cấu trúc Files

```
day5/
├── main.tf                     # Module chính
├── variables.tf                # Variable definitions với validation
├── providers.tf                # AWS provider configuration
├── outputs.tf                  # Outputs
├── versions.tf                 # Version constraints
├── .gitignore                  # Git ignore rules
├── terraform.tfvars.example    # Example configuration
├── environments/               # Environment-specific configs
│   ├── dev.tfvars             # Development configuration
│   ├── test.tfvars            # Test configuration
│   └── prod.tfvars            # Production configuration
├── setup-workspaces.sh         # Script setup workspace
├── deploy-env.sh              # Script deploy với tfvars
├── Makefile                   # Make commands với tfvars
└── modules/                   # Terraform modules
```

## ⚙️ Cấu hình Môi trường

| Môi trường | VPC CIDR    | Subnet CIDR | AZ              | Instance Type | Monitoring | Backup (days) |
| ---------- | ----------- | ----------- | --------------- | ------------- | ---------- | ------------- |
| **dev**    | 10.0.0.0/16 | 10.0.1.0/24 | ap-southeast-1a | t2.micro      | ❌         | 3             |
| **test**   | 10.1.0.0/16 | 10.1.1.0/24 | ap-southeast-1b | t2.small      | ✅         | 5             |
| **prod**   | 10.2.0.0/16 | 10.2.1.0/24 | ap-southeast-1c | t2.medium     | ✅         | 14            |

## 🚀 Cách Sử dụng

### 1. Setup ban đầu

```bash
# Cách 1: Sử dụng script (recommended)
./setup-workspaces.sh

# Cách 2: Sử dụng Makefile
make setup-workspaces

# Cách 3: Manual
terraform init
terraform workspace new dev
terraform workspace new test
terraform workspace new prod
```

### 2. Triển khai môi trường

#### 🎯 **Sử dụng Script (Recommended)**

```bash
./deploy-env.sh dev   # Triển khai dev với dev.tfvars
./deploy-env.sh test  # Triển khai test với test.tfvars
./deploy-env.sh prod  # Triển khai prod với prod.tfvars
```

#### 🎯 **Sử dụng Makefile với tfvars**

```bash
make apply-dev   # Triển khai dev với environments/dev.tfvars
make apply-test  # Triển khai test với environments/test.tfvars
make apply-prod  # Triển khai prod với environments/prod.tfvars
```

#### Manual với tfvars

```bash
# Triển khai dev
terraform workspace select dev
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# Triển khai test
terraform workspace select test
terraform plan -var-file=environments/test.tfvars
terraform apply -var-file=environments/test.tfvars

# Triển khai prod
terraform workspace select prod
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

### 3. Quản lý Configuration

#### Chỉnh sửa cấu hình môi trường

```bash
# Chỉnh sửa config dev
vim environments/dev.tfvars

# Chỉnh sửa config test
vim environments/test.tfvars

# Chỉnh sửa config prod
vim environments/prod.tfvars
```

#### Tạo custom configuration

```bash
# Copy example file
cp terraform.tfvars.example my-custom.tfvars

# Chỉnh sửa và sử dụng
terraform plan -var-file=my-custom.tfvars
```

## 📝 Makefile Commands (với tfvars)

```bash
make help              # Xem tất cả commands
make init              # Khởi tạo terraform
make setup-workspaces  # Setup workspace
make check-tfvars      # Kiểm tra tfvars files

# Validation commands (NEW!)
make validate-dev      # Validate dev config
make validate-test     # Validate test config
make validate-prod     # Validate prod config

# Plan commands với tfvars
make plan-dev          # Plan dev với dev.tfvars
make plan-test         # Plan test với test.tfvars
make plan-prod         # Plan prod với prod.tfvars

# Apply commands với tfvars
make apply-dev         # Deploy dev với dev.tfvars
make apply-test        # Deploy test với test.tfvars
make apply-prod        # Deploy prod với prod.tfvars

# Output commands
make output-dev        # Output dev
make output-test       # Output test
make output-prod       # Output prod

# Destroy commands với tfvars
make destroy-dev       # Destroy dev với dev.tfvars
make destroy-test      # Destroy test với test.tfvars
make destroy-prod      # Destroy prod với prod.tfvars
```

## 🔒 Security & Best Practices

### File Protection

```bash
# .gitignore tự động protect:
terraform.tfvars       # Personal configs
*.auto.tfvars         # Auto-loaded files
secrets.tfvars        # Sensitive data
local.tfvars          # Local overrides

# Safe to commit:
environments/*.tfvars  # Environment configs
terraform.tfvars.example  # Example file
```

### Variable Validation

```hcl
# Tất cả variables có validation rules:
variable "environment" {
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "instance_type" {
  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium", "t2.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}
```

### Environment-specific Settings

```hcl
# Locals tự động adapt theo environment:
locals {
  is_production = var.environment == "prod"
  detailed_monitoring = var.environment == "prod" ? true : var.enable_monitoring

  common_tags = {
    Environment  = var.environment
    Project      = var.project_name
    Owner        = var.owner
    ManagedBy    = "Terraform"
    Workspace    = terraform.workspace
    LastModified = timestamp()
  }
}
```

## 🎯 Ví dụ workflow hoàn chỉnh

```bash
# 1. Setup
make setup-workspaces
make check-tfvars

# 2. Validate configurations
make validate-dev
make validate-test
make validate-prod

# 3. Phát triển trên dev
make plan-dev      # Review changes
make apply-dev     # Deploy
make output-dev    # Check results

# 4. Test trên test environment
make plan-test
make apply-test
make output-test

# 5. Deploy production (cẩn thận!)
make plan-prod     # Double check!
make apply-prod    # Deploy to prod
make output-prod

# 6. Cleanup khi cần
make destroy-dev
make destroy-test
```

## 🔄 Migration từ hard-coded locals

Nếu bạn đang sử dụng hard-coded locals, migration sang tfvars:

```bash
# 1. Backup current state
cp terraform.tfstate terraform.tfstate.backup

# 2. Update code (đã hoàn thành)
# 3. Create tfvars files (đã có sẵn)

# 4. Test với workspace dev
terraform workspace select dev
terraform plan -var-file=environments/dev.tfvars

# 5. Apply từng môi trường
make apply-dev
make apply-test
make apply-prod
```

## 📞 Troubleshooting

**tfvars file không tồn tại?**

```bash
make check-tfvars  # Kiểm tra files
cp terraform.tfvars.example environments/custom.tfvars
```

**Validation error?**

```bash
make validate-dev  # Check specific environment
terraform fmt      # Format code
terraform validate # Basic validation
```

**Workspace không tồn tại?**

```bash
terraform workspace new <env-name>
```

**State file conflicts?**

```bash
terraform state list
terraform refresh -var-file=environments/<env>.tfvars
```

## 🏆 **Kết luận: tfvars là Best Practice!**

✅ **Advantages của tfvars approach:**

- Tách biệt hoàn toàn code và configuration
- Dễ dàng customize cho từng môi trường
- Bảo mật tốt hơn với .gitignore
- Validation tự động
- Team collaboration friendly
- CI/CD ready

✅ **So với hard-coded locals:**

- Flexible hơn - không cần sửa code để đổi config
- Secure hơn - sensitive values không commit
- Scalable hơn - dễ thêm môi trường mới
- Professional hơn - industry standard
