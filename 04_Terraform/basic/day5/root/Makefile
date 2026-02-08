# Makefile for Terraform Workspace Management with tfvars

.PHONY: help init setup-workspaces list-workspaces current-workspace
.PHONY: select-dev select-test select-prod
.PHONY: plan-dev plan-test plan-prod
.PHONY: apply-dev apply-test apply-prod
.PHONY: destroy-dev destroy-test destroy-prod
.PHONY: output-dev output-test output-prod
.PHONY: validate-dev validate-test validate-prod
.PHONY: clean check-tfvars

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

# Environment-specific tfvars files
DEV_TFVARS=environments/dev.tfvars
TEST_TFVARS=environments/test.tfvars
PROD_TFVARS=environments/prod.tfvars

help: ## Hiển thị trợ giúp
	@echo "$(YELLOW)Terraform Workspace Management với tfvars$(NC)"
	@echo ""
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  make init              - Khởi tạo Terraform"
	@echo "  make setup-workspaces  - Tạo tất cả workspace (dev, test, prod)"
	@echo "  make check-tfvars      - Kiểm tra files tfvars"
	@echo ""
	@echo "$(GREEN)Workspace Commands:$(NC)"
	@echo "  make list-workspaces   - Liệt kê tất cả workspace"
	@echo "  make current-workspace - Xem workspace hiện tại"
	@echo "  make select-dev        - Chuyển sang workspace dev"
	@echo "  make select-test       - Chuyển sang workspace test"
	@echo "  make select-prod       - Chuyển sang workspace prod"
	@echo ""
	@echo "$(GREEN)Validation Commands:$(NC)"
	@echo "  make validate-dev      - Validate cấu hình dev"
	@echo "  make validate-test     - Validate cấu hình test"
	@echo "  make validate-prod     - Validate cấu hình prod"
	@echo ""
	@echo "$(GREEN)Plan Commands:$(NC)"
	@echo "  make plan-dev          - Plan cho môi trường dev"
	@echo "  make plan-test         - Plan cho môi trường test"
	@echo "  make plan-prod         - Plan cho môi trường prod"
	@echo ""
	@echo "$(GREEN)Apply Commands:$(NC)"
	@echo "  make apply-dev         - Triển khai môi trường dev"
	@echo "  make apply-test        - Triển khai môi trường test"
	@echo "  make apply-prod        - Triển khai môi trường prod"
	@echo ""
	@echo "$(GREEN)Output Commands:$(NC)"
	@echo "  make output-dev        - Xem output môi trường dev"
	@echo "  make output-test       - Xem output môi trường test"
	@echo "  make output-prod       - Xem output môi trường prod"
	@echo ""
	@echo "$(GREEN)Destroy Commands:$(NC)"
	@echo "  make destroy-dev       - Hủy môi trường dev"
	@echo "  make destroy-test      - Hủy môi trường test"
	@echo "  make destroy-prod      - Hủy môi trường prod"
	@echo ""
	@echo "$(GREEN)Other Commands:$(NC)"
	@echo "  make clean             - Dọn dẹp files tạm"

init: ## Khởi tạo Terraform
	@echo "$(GREEN)Khởi tạo Terraform...$(NC)"
	terraform init

check-tfvars: ## Kiểm tra files tfvars
	@echo "$(YELLOW)Kiểm tra files tfvars...$(NC)"
	@for env in dev test prod; do \
		if [ -f "environments/$$env.tfvars" ]; then \
			echo "$(GREEN)✓$(NC) environments/$$env.tfvars"; \
		else \
			echo "$(RED)✗$(NC) environments/$$env.tfvars - File không tồn tại"; \
		fi \
	done

setup-workspaces: init check-tfvars ## Tạo tất cả workspace
	@echo "$(GREEN)Tạo các workspace...$(NC)"
	@terraform workspace new dev 2>/dev/null || echo "Workspace dev đã tồn tại"
	@terraform workspace new test 2>/dev/null || echo "Workspace test đã tồn tại"
	@terraform workspace new prod 2>/dev/null || echo "Workspace prod đã tồn tại"
	@echo "$(GREEN)Setup hoàn tất!$(NC)"
	@make list-workspaces

list-workspaces: ## Liệt kê tất cả workspace
	@echo "$(YELLOW)Danh sách workspace:$(NC)"
	@terraform workspace list

current-workspace: ## Xem workspace hiện tại
	@echo "$(YELLOW)Workspace hiện tại:$(NC) $$(terraform workspace show)"

# Workspace Selection
select-dev: ## Chuyển sang workspace dev
	@echo "$(GREEN)Chuyển sang workspace dev...$(NC)"
	@terraform workspace select dev
	@make current-workspace

select-test: ## Chuyển sang workspace test
	@echo "$(GREEN)Chuyển sang workspace test...$(NC)"
	@terraform workspace select test
	@make current-workspace

select-prod: ## Chuyển sang workspace prod
	@echo "$(GREEN)Chuyển sang workspace prod...$(NC)"
	@terraform workspace select prod
	@make current-workspace

# Validation Commands
validate-dev: select-dev ## Validate cấu hình dev
	@echo "$(YELLOW)Validating cấu hình dev...$(NC)"
	@terraform validate
	@terraform fmt -check

validate-test: select-test ## Validate cấu hình test
	@echo "$(YELLOW)Validating cấu hình test...$(NC)"
	@terraform validate
	@terraform fmt -check

validate-prod: select-prod ## Validate cấu hình prod
	@echo "$(YELLOW)Validating cấu hình prod...$(NC)"
	@terraform validate
	@terraform fmt -check

# Plan Commands
plan-dev: select-dev ## Plan cho môi trường dev
	@echo "$(YELLOW)Planning cho môi trường dev...$(NC)"
	terraform plan -var-file=$(DEV_TFVARS)

plan-test: select-test ## Plan cho môi trường test
	@echo "$(YELLOW)Planning cho môi trường test...$(NC)"
	terraform plan -var-file=$(TEST_TFVARS)

plan-prod: select-prod ## Plan cho môi trường prod
	@echo "$(YELLOW)Planning cho môi trường prod...$(NC)"
	terraform plan -var-file=$(PROD_TFVARS)

# Apply Commands
apply-dev: select-dev ## Triển khai môi trường dev
	@echo "$(GREEN)Triển khai môi trường dev...$(NC)"
	terraform apply -var-file=$(DEV_TFVARS)

apply-test: select-test ## Triển khai môi trường test
	@echo "$(GREEN)Triển khai môi trường test...$(NC)"
	terraform apply -var-file=$(TEST_TFVARS)

apply-prod: select-prod ## Triển khai môi trường prod
	@echo "$(RED)Cảnh báo: Đang triển khai môi trường PRODUCTION!$(NC)"
	@read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " confirm && [ "$$confirm" = "y" ]
	terraform apply -var-file=$(PROD_TFVARS)

# Output Commands
output-dev: select-dev ## Xem output môi trường dev
	@echo "$(YELLOW)Output môi trường dev:$(NC)"
	@terraform output

output-test: select-test ## Xem output môi trường test
	@echo "$(YELLOW)Output môi trường test:$(NC)"
	@terraform output

output-prod: select-prod ## Xem output môi trường prod
	@echo "$(YELLOW)Output môi trường prod:$(NC)"
	@terraform output

# Destroy Commands
destroy-dev: select-dev ## Hủy môi trường dev
	@echo "$(RED)Hủy môi trường dev...$(NC)"
	terraform destroy -var-file=$(DEV_TFVARS)

destroy-test: select-test ## Hủy môi trường test
	@echo "$(RED)Hủy môi trường test...$(NC)"
	terraform destroy -var-file=$(TEST_TFVARS)

destroy-prod: select-prod ## Hủy môi trường prod
	@echo "$(RED)CẢNH BÁO: Đang hủy môi trường PRODUCTION!$(NC)"
	@read -p "Bạn có THỰC SỰ chắc chắn muốn hủy PRODUCTION? (yes/N): " confirm && [ "$$confirm" = "yes" ]
	terraform destroy -var-file=$(PROD_TFVARS)

clean: ## Dọn dẹp files tạm
	@echo "$(YELLOW)Dọn dẹp files tạm...$(NC)"
	@rm -f *.log
	@rm -f .terraform.lock.hcl
	@echo "$(GREEN)Dọn dẹp hoàn tất!$(NC)" 