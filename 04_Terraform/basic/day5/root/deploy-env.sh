#!/bin/bash

# Script triển khai các môi trường với tfvars
ENV=$1

if [ -z "$ENV" ]; then
    echo "Sử dụng: ./deploy-env.sh [dev|test|prod]"
    echo ""
    echo "Ví dụ:"
    echo "  ./deploy-env.sh dev   # Triển khai môi trường dev"
    echo "  ./deploy-env.sh test  # Triển khai môi trường test"
    echo "  ./deploy-env.sh prod  # Triển khai môi trường prod"
    exit 1
fi

# Kiểm tra môi trường hợp lệ
if [[ ! "$ENV" =~ ^(dev|test|prod)$ ]]; then
    echo "Lỗi: Môi trường không hợp lệ. Chỉ chấp nhận: dev, test, prod"
    exit 1
fi

# Kiểm tra file tfvars tồn tại
TFVARS_FILE="environments/${ENV}.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    echo "Lỗi: File cấu hình $TFVARS_FILE không tồn tại"
    echo "Vui lòng tạo file cấu hình cho môi trường $ENV"
    exit 1
fi

echo "=== Triển khai môi trường: $ENV ==="
echo "Sử dụng file cấu hình: $TFVARS_FILE"
echo ""

# Chuyển workspace
echo "1. Chuyển sang workspace: $ENV"
terraform workspace select $ENV

# Kiểm tra workspace hiện tại
CURRENT_WORKSPACE=$(terraform workspace show)
echo "Workspace hiện tại: $CURRENT_WORKSPACE"

if [ "$CURRENT_WORKSPACE" != "$ENV" ]; then
    echo "Lỗi: Không thể chuyển sang workspace $ENV"
    exit 1
fi

echo ""
echo "2. Kiểm tra plan với cấu hình $ENV..."
terraform plan -var-file="$TFVARS_FILE"

echo ""
read -p "Bạn có muốn tiếp tục triển khai? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "3. Bắt đầu triển khai với cấu hình $ENV..."
    terraform apply -var-file="$TFVARS_FILE" -auto-approve
    
    echo ""
    echo "=== Triển khai hoàn tất cho môi trường: $ENV ==="
    echo ""
    echo "Outputs:"
    terraform output
else
    echo ""
    echo "Hủy triển khai."
fi 