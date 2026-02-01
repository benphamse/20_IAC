# Hướng dẫn sử dụng Terraform Workspace

## Tổng quan

Terraform workspace cho phép bạn quản lý nhiều môi trường (dev, test, prod) từ cùng một codebase mà không cần tạo nhiều thư mục riêng biệt.

## Cấu trúc môi trường

- **dev**: Môi trường phát triển (VPC: 10.0.0.0/16, Instance: t2.micro)
- **test**: Môi trường kiểm thử (VPC: 10.1.0.0/16, Instance: t2.small)
- **prod**: Môi trường sản xuất (VPC: 10.2.0.0/16, Instance: t2.medium)

## Các lệnh cơ bản

### 1. Xem workspace hiện tại

```bash
terraform workspace show
```

### 2. Liệt kê tất cả workspace

```bash
terraform workspace list
```

### 3. Tạo workspace mới

```bash
# Tạo workspace dev
terraform workspace new dev

# Tạo workspace test
terraform workspace new test

# Tạo workspace prod
terraform workspace new prod
```

### 4. Chuyển đổi workspace

```bash
# Chuyển sang workspace dev
terraform workspace select dev

# Chuyển sang workspace test
terraform workspace select test

# Chuyển sang workspace prod
terraform workspace select prod
```

### 5. Xóa workspace

```bash
terraform workspace delete test
```

## Quy trình triển khai

### Triển khai môi trường DEV

```bash
# Chuyển sang workspace dev
terraform workspace select dev

# Khởi tạo và kiểm tra plan
terraform init
terraform plan

# Triển khai
terraform apply
```

### Triển khai môi trường TEST

```bash
# Chuyển sang workspace test
terraform workspace select test

# Kiểm tra plan và triển khai
terraform plan
terraform apply
```

### Triển khai môi trường PROD

```bash
# Chuyển sang workspace prod
terraform workspace select prod

# Kiểm tra plan và triển khai
terraform plan
terraform apply
```

## State file

Mỗi workspace sẽ có state file riêng biệt:

- `terraform.tfstate.d/dev/terraform.tfstate`
- `terraform.tfstate.d/test/terraform.tfstate`
- `terraform.tfstate.d/prod/terraform.tfstate`

## Lưu ý quan trọng

1. Luôn kiểm tra workspace hiện tại trước khi chạy terraform commands
2. State files được tách biệt cho từng workspace
3. Mỗi môi trường có cấu hình riêng (CIDR, instance type, etc.)
4. Tags sẽ tự động được gán theo workspace
