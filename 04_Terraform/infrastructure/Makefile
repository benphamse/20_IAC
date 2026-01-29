# Makefile for Terraform Enterprise Infrastructure

.PHONY: help setup-backend init-dev init-prod plan-dev plan-prod apply-dev apply-prod destroy-dev destroy-prod fmt validate clean

# Default environment
ENV ?= dev

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Terraform Enterprise Infrastructure$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Backend Setup
setup-backend: ## Setup backend infrastructure (S3 + DynamoDB)
	@echo "$(BLUE)Setting up backend infrastructure...$(NC)"
	cd backend-setup && terraform init && terraform plan -out=tfplan && terraform apply tfplan && rm -f tfplan

init-backend: ## Initialize backend setup
	@echo "$(BLUE)Initializing backend setup...$(NC)"
	cd backend-setup && terraform init

plan-backend: ## Plan backend infrastructure
	@echo "$(BLUE)Planning backend infrastructure...$(NC)"
	cd backend-setup && terraform plan -out=tfplan

apply-backend: ## Apply backend infrastructure
	@echo "$(YELLOW)Applying backend infrastructure...$(NC)"
	cd backend-setup && terraform apply tfplan && rm -f tfplan

# Development Environment
init-dev: ## Initialize Terraform for development environment
	@echo "$(BLUE)Initializing development environment...$(NC)"
	cd environments/dev && terraform init -backend-config=backend.hcl -upgrade

plan-dev: ## Plan deployment for development environment
	@echo "$(BLUE)Planning development environment...$(NC)"
	cd environments/dev && terraform plan -var-file="terraform.tfvars" -out="tfplan"

apply-dev: ## Apply changes to development environment
	@echo "$(YELLOW)Applying changes to development environment...$(NC)"
	cd environments/dev && terraform apply "tfplan"

destroy-dev: ## Destroy development environment
	@echo "$(RED)Destroying development environment...$(NC)"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd environments/dev && terraform destroy -var-file="terraform.tfvars" -auto-approve; \
	fi

# Production Environment
init-prod: ## Initialize Terraform for production environment
	@echo "$(BLUE)Initializing production environment...$(NC)"
	cd environments/prod && terraform init -backend-config=backend.hcl -upgrade

plan-prod: ## Plan deployment for production environment
	@echo "$(BLUE)Planning production environment...$(NC)"
	cd environments/prod && terraform plan -var-file="terraform.tfvars" -out="tfplan"

apply-prod: ## Apply changes to production environment
	@echo "$(YELLOW)Applying changes to production environment...$(NC)"
	@read -p "Are you sure you want to deploy to PRODUCTION? (y/N): " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd environments/prod && terraform apply "tfplan"; \
	fi

destroy-prod: ## Destroy production environment
	@echo "$(RED)WARNING: This will destroy the PRODUCTION environment!$(NC)"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		cd environments/prod && terraform destroy -var-file="terraform.tfvars" -auto-approve; \
	else \
		echo "$(BLUE)Operation cancelled$(NC)"; \
	fi

# Utility Commands
fmt: ## Format all Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	terraform fmt -recursive .

validate: ## Validate all Terraform configurations
	@echo "$(BLUE)Validating Terraform configurations...$(NC)"
	@for env in dev prod; do \
		echo "Validating $$env environment..."; \
		cd environments/$$env && terraform validate; \
		cd ../..; \
	done

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	find . -name "*.tfplan" -delete
	find . -name ".terraform.lock.hcl" -delete
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

# Output commands
output-dev: ## Show outputs for development environment
	@cd environments/dev && terraform output

output-prod: ## Show outputs for production environment
	@cd environments/prod && terraform output

# Security scan (requires tfsec)
security-scan: ## Run security scan on Terraform code
	@if command -v tfsec >/dev/null 2>&1; then \
		echo "$(BLUE)Running security scan...$(NC)"; \
		tfsec .; \
	else \
		echo "$(YELLOW)tfsec not installed. Install with: brew install tfsec$(NC)"; \
	fi

# Cost estimation (requires infracost)
cost-estimate-dev: ## Estimate costs for development environment
	@if command -v infracost >/dev/null 2>&1; then \
		echo "$(BLUE)Estimating costs for development...$(NC)"; \
		cd environments/dev && infracost breakdown --path .; \
	else \
		echo "$(YELLOW)infracost not installed. See: https://www.infracost.io/docs/$(NC)"; \
	fi

cost-estimate-prod: ## Estimate costs for production environment
	@if command -v infracost >/dev/null 2>&1; then \
		echo "$(BLUE)Estimating costs for production...$(NC)"; \
		cd environments/prod && infracost breakdown --path .; \
	else \
		echo "$(YELLOW)infracost not installed. See: https://www.infracost.io/docs/$(NC)"; \
	fi

# Complete workflow
deploy-dev: init-dev validate fmt plan-dev apply-dev ## Complete deployment workflow for development

deploy-prod: init-prod validate fmt plan-prod apply-prod ## Complete deployment workflow for production

# Status check
status: ## Show status of all environments
	@echo "$(BLUE)Infrastructure Status:$(NC)"
	@echo ""
	@for env in dev prod; do \
		echo "$(YELLOW)$$env environment:$(NC)"; \
		if [ -f "environments/$$env/terraform.tfstate" ]; then \
			echo "  Status: $(GREEN)Deployed$(NC)"; \
			cd environments/$$env && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[]?.address' 2>/dev/null | wc -l | xargs echo "  Resources:" || echo "  Resources: Unknown"; \
			cd ../..; \
		else \
			echo "  Status: $(RED)Not deployed$(NC)"; \
		fi; \
		echo ""; \
	done
