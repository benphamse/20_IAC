# Terraform Backend Setup Guide

## Tổng quan

Dự án này đã được cấu hình với backend hoàn chỉnh để lưu trữ Terraform state file một cách an toàn và hiệu quả. Backend sử dụng:

- **S3 Bucket**: Lưu trữ state file với encryption và versioning
- **DynamoDB Table**: Khóa state để tránh xung đột khi nhiều người cùng làm việc
- **IAM Policies**: Quyền truy cập bảo mật cho backend
- **CloudWatch Monitoring**: Theo dõi hoạt động backend (tùy chọn)

## Cấu trúc thư mục

```
infrastructure/
├── backend-setup/          # Setup backend infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
├── modules/backend/        # Backend module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── README.md
├── environments/
│   ├── dev/
│   │   └── backend.hcl     # Backend config cho dev
│   └── prod/
│       └── backend.hcl     # Backend config cho prod
└── scripts/
    └── deploy.sh           # Script tự động deploy
```

## Hướng dẫn sử dụng

### Bước 1: Thiết lập Backend Infrastructure

```bash
# Sử dụng Makefile
make setup-backend

# Hoặc sử dụng script
./scripts/deploy.sh setup

# Hoặc thực hiện thủ công
cd backend-setup
terraform init
terraform plan
terraform apply
```

### Bước 2: Cấu hình Environment

Sau khi setup backend, các file `backend.hcl` sẽ được tự động cập nhật với thông tin thực tế:

```hcl
# environments/dev/backend.hcl
bucket         = "devops-fresher-dev-terraform-state-abcd1234"
key            = "environments/dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "devops-fresher-dev-terraform-locks"
```

### Bước 3: Khởi tạo Environment với Remote State

```bash
# Development
cd environments/dev
terraform init -backend-config=backend.hcl

# Production
cd environments/prod
terraform init -backend-config=backend.hcl
```

### Bước 4: Deploy Environment

```bash
# Sử dụng Makefile
make init-dev
make plan-dev
make apply-dev

# Hoặc sử dụng script
./scripts/deploy.sh dev

# Hoặc thực hiện thủ công
cd environments/dev
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Các lệnh hữu ích

### Makefile Commands

```bash
make help                 # Hiển thị trợ giúp
make setup-backend        # Thiết lập backend infrastructure
make init-dev            # Khởi tạo development environment
make plan-dev            # Lập kế hoạch cho development
make apply-dev           # Áp dụng thay đổi cho development
make init-prod           # Khởi tạo production environment
make plan-prod           # Lập kế hoạch cho production
make apply-prod          # Áp dụng thay đổi cho production
```

### Script Commands

```bash
./scripts/deploy.sh setup    # Thiết lập backend
./scripts/deploy.sh dev      # Deploy development
./scripts/deploy.sh prod     # Deploy production
./scripts/deploy.sh all      # Thiết lập backend và deploy tất cả
```

## Tính năng bảo mật

- **Encryption**: Tất cả dữ liệu được mã hóa
- **Versioning**: Theo dõi lịch sử thay đổi state
- **Access Control**: IAM policies hạn chế quyền truy cập
- **Public Access Blocked**: Không cho phép truy cập công khai
- **State Locking**: Tránh xung đột khi làm việc nhóm

## Quản lý chi phí

- **S3 Lifecycle**: Tự động xóa version cũ sau 30 ngày
- **DynamoDB**: Sử dụng pay-per-request billing
- **Monitoring**: Tùy chọn để kiểm soát chi phí

## Troubleshooting

### Lỗi thường gặp

1. **Bucket name conflicts**: Tên bucket phải unique toàn cầu
2. **Permission denied**: Kiểm tra AWS credentials và IAM permissions
3. **Backend not initialized**: Chạy `terraform init -backend-config=backend.hcl`
4. **State locked**: Ai đó đang chạy terraform, chờ hoặc unlock thủ công

### Unlock state (khi bị lock)

```bash
# Chỉ sử dụng khi chắc chắn không ai đang chạy terraform
terraform force-unlock <LOCK_ID>
```

### Migrate existing state

```bash
# Nếu bạn có state file cũ
terraform init -migrate-state -backend-config=backend.hcl
```

## Backup và Recovery

- State file được tự động backup với S3 versioning
- DynamoDB có thể bật Point-in-Time Recovery
- CloudWatch logs ghi lại mọi hoạt động

## Best Practices

1. **Luôn sử dụng backend**: Không lưu state file local
2. **Kiểm tra state lock**: Đảm bảo không có ai đang chạy terraform
3. **Backup định kỳ**: Tuy có versioning nhưng nên backup riêng
4. **Phân quyền**: Chỉ cho phép người có thẩm quyền access production
5. **Monitoring**: Bật CloudWatch để theo dõi hoạt động

## Liên hệ hỗ trợ

Nếu gặp vấn đề, vui lòng:

1. Kiểm tra logs trong CloudWatch
2. Xem lại file README.md trong từng module
3. Liên hệ DevOps team để được hỗ trợ
