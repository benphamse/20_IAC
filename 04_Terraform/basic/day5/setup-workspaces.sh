#!/bin/bash

echo "=== Terraform Workspace Setup Script ==="
echo ""

# Khởi tạo terraform
echo "1. Khởi tạo Terraform..."
terraform init

echo ""
echo "2. Tạo các workspace..."

# Tạo workspace dev
echo "Tạo workspace: dev"
terraform workspace new dev 2>/dev/null || echo "Workspace dev đã tồn tại"

# Tạo workspace test  
echo "Tạo workspace: test"
terraform workspace new test 2>/dev/null || echo "Workspace test đã tồn tại"

# Tạo workspace prod
echo "Tạo workspace: prod"
terraform workspace new prod 2>/dev/null || echo "Workspace prod đã tồn tại"

echo ""
echo "3. Liệt kê tất cả workspace:"
terraform workspace list

echo ""
echo "4. Workspace hiện tại:"
terraform workspace show

echo ""
echo "=== Setup hoàn tất! ==="
echo ""
echo "Để sử dụng:"
echo "- terraform workspace select dev    # Chuyển sang dev"
echo "- terraform workspace select test   # Chuyển sang test"  
echo "- terraform workspace select prod   # Chuyển sang prod"
echo ""
echo "Sau đó chạy:"
echo "- terraform plan    # Xem thay đổi"
echo "- terraform apply   # Triển khai" 