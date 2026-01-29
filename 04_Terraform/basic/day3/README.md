📁 Cấu hình cho các môi trường:

🔧 Production Environment (envs/prod/terraform.tfvars):

- Instance type: t3.small (lớn hơn cho production workload)
- VPC CIDR: 10.1.0.0/16 (tránh conflict với dev)
- Subnets: 10.1.1.0/24 và 10.1.2.0/24
- Tags: web-app-prod, owner: DevOps Team

🧪 Test Environment (envs/test/terraform.tfvars):

- Instance type: t2.micro (nhỏ gọn cho testing)
- VPC CIDR: 10.2.0.0/16 (tách biệt với dev và prod)
- Subnets: 10.2.1.0/24 và 10.2.2.0/24
- Tags: web-app-test, owner: QA Team

🛠️ Development Environment (đã cập nhật):

- Instance type: t2.micro
- VPC CIDR: 10.0.0.0/16
- Subnets: 10.0.1.0/24 và 10.0.2.0/24
- Tags: web-app-dev, owner: Development Team
  🚀 Scripts Deploy đã tạo:

```plaintext
1. deploy-dev.bat - Deploy môi trường Development

- Khởi tạo Terraform
- Tạo plan với dev config
- Xác nhận trước khi apply

2. deploy-prod.bat - Deploy môi trường Production

- Có cảnh báo đặc biệt cho production
- Yêu cầu xác nhận 2 lần (yes/no)
- Review plan cẩn thận trước khi deploy

3. deploy-test.bat - Deploy môi trường Test

- Đơn giản hóa cho testing nhanh
- Xác nhận cơ bản trước khi apply

```

🔧 Cải tiến trong Main Configuration:

- Dynamic naming: Resources sẽ có tên theo pattern {project_name}-{environment}
- Variable support: Hỗ trợ đầy đủ các biến cho từng môi trường
- Environment isolation: Mỗi môi trường có CIDR riêng biệt

📋 Cách sử dụng:

```shell
# Deploy Development
./deploy-dev.bat

# Deploy Test
./deploy-test.bat

# Deploy Production (cẩn thận!)
./deploy-prod.bat
```

Hoặc deploy thủ công:

```shell

# Development

terraform plan -var-file="envs/dev/terraform.tfvars"
terraform apply -var-file="envs/dev/terraform.tfvars"

# Production

terraform plan -var-file="envs/prod/terraform.tfvars"
terraform apply -var-file="envs/prod/terraform.tfvars"

# Test

terraform plan -var-file="envs/test/terraform.tfvars"
terraform apply -var-file="envs/test/terraform.tfvars"

```

Bây giờ dự án đã được cấu hình đầy đủ cho 3 môi trường với các tính năng:
✅ Tách biệt network (khác CIDR)
✅ Instance size phù hợp từng môi trường
✅ Naming convention rõ ràng
✅ Scripts deploy tiện lợi
✅ Production safeguards

Makefile Chính với 25+ commands:

Core Commands:

```shell
make help - Hiển thị tất cả commands có sẵn
make init ENV=<env> - Khởi tạo Terraform
make plan ENV=<env> - Tạo execution plan
make apply ENV=<env> - Deploy infrastructure
make destroy ENV=<env> - Xóa infrastructure
make validate - Validate cấu hình
make format - Format code Terraform
```

Environment Shortcuts:

```shell
make dev-apply - Deploy development nhanh
make test-apply - Deploy test nhanh
make prod-apply - Deploy production (có safety check)
```

Utility Commands:

```shell
make show-envs - Hiển thị config của tất cả environments
make outputs ENV=<env> - Xem outputs
make status ENV=<env> - Kiểm tra trạng thái infrastructure
make clean - Dọn dẹp files tạm
```

🛠️ Bash Scripts (9 scripts):

```shell
1. terraform-init.sh - Khởi tạo Terraform
   Validate environment
   Check tfvars files
   Clean init với error handling
2. terraform-plan.sh - Tạo execution plan
   Tạo plan file cho từng environment
   Error handling và validation
3. terraform-apply.sh - Deploy infrastructure
   Production safety checks (yêu cầu confirm)
   Apply plan files hoặc direct apply
   Show outputs sau khi deploy
4. terraform-destroy.sh - Xóa infrastructure
   Multiple safety confirmations
   Special protection cho production
   Cleanup sau khi destroy
5. terraform-validate.sh - Validate toàn bộ project
   Validate main config
   Validate tất cả modules
   Validate environment configs
   Check code formatting
6. show-environments.sh - Hiển thị config environments
   Parse và hiển thị config từng environment
   Show quick commands
   Project structure overview
7. clean.sh - Dọn dẹp files
   Remove plan files, crash logs
   Optional backup cleanup
   Safe cleanup với confirmation
8. terraform-outputs.sh - Hiển thị outputs
   Format outputs đẹp với colors
   Extract key information (URLs, IPs)
   Connection information
9. terraform-status.sh - Kiểm tra trạng thái
   Check init status
   Resource count
   AWS resources summary
   ```

Available actions

✨ Features Đặc Biệt:

🔒 Production Safety:

Multiple confirmations cho production
Special safety messages
Protected destroy operations

🎨 Color-coded Output:

INFO (Blue), SUCCESS (Green), WARNING (Yellow), ERROR (Red)
Easy to read và professional

📊 Smart Status Checking:

Auto-detect infrastructure state
Resource counting
Last modified tracking

🚀 Cách Sử dụng:

```shell
# Xem tất cả commands
make help

# Setup nhanh
./quick-setup.sh

# Xem environments
make show-envs

# Deploy development
make dev-apply

# Deploy test
make test-apply

# Deploy production (cẩn thận!)
make prod-apply

# Kiểm tra trạng thái
make status ENV=dev

# Xem outputs
make outputs ENV=dev

# Validate toàn bộ
make validate

# Dọn dẹp
make clean
```

📁 Cấu trúc Script đã tạo:

```plaintext
scripts/
├── terraform-init.sh # Khởi tạo
├── terraform-plan.sh # Planning
├── terraform-apply.sh # Deployment
├── terraform-destroy.sh # Destruction
├── terraform-validate.sh # Validation
├── terraform-outputs.sh # Outputs
├── terraform-status.sh # Status check
├── show-environments.sh # Environment info
├── clean.sh # Cleanup
└── install-tools.sh # Tool installation
```

    Tất cả scripts đã được set executable permissions và ready to use! Hệ thống này cung cấp:
    ✅ Multi-environment support (dev/test/prod)
    ✅ Safety mechanisms cho production
    ✅ Error handling và logging
    ✅ Color-coded output
    ✅ Comprehensive validation
    ✅ Easy cleanup và maintenance