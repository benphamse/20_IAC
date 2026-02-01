# Makefile for Terraform Multi-Environment Management
# Author: DevOps Team
# Date: July 7, 2025

# Variables
TERRAFORM_VERSION := 1.14.0
AWS_REGION := us-east-1
PROJECT_NAME := web-app
ENVIRONMENTS := dev test prod

# Colors for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
WHITE := \033[37m
RESET := \033[0m

# Default environment
ENV ?= dev

.PHONY: help init plan apply destroy validate format lint clean status outputs show-envs

# Default target
help: ## Show this help message
	@echo "$(CYAN)========================================$(RESET)"
	@echo "$(CYAN)  Terraform Multi-Environment Manager  $(RESET)"
	@echo "$(CYAN)========================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)  %-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage examples:$(RESET)"
	@echo "  $(WHITE)make init ENV=dev$(RESET)      - Initialize dev environment"
	@echo "  $(WHITE)make plan ENV=prod$(RESET)     - Plan prod deployment"
	@echo "  $(WHITE)make apply ENV=test$(RESET)    - Apply test configuration"
	@echo "  $(WHITE)make destroy ENV=dev$(RESET)   - Destroy dev resources"
	@echo ""
	@echo "$(YELLOW)Available environments:$(RESET) $(GREEN)$(ENVIRONMENTS)$(RESET)"

init: ## Initialize Terraform for specified environment
	@echo "$(BLUE)Initializing Terraform for $(ENV) environment...$(RESET)"
	@./scripts/terraform-init.sh $(ENV)

plan: ## Create execution plan for specified environment
	@echo "$(YELLOW)Planning deployment for $(ENV) environment...$(RESET)"
	@./scripts/terraform-plan.sh $(ENV)

apply: ## Apply Terraform configuration for specified environment
	@echo "$(GREEN)Applying configuration for $(ENV) environment...$(RESET)"
	@./scripts/terraform-apply.sh $(ENV)

destroy: ## Destroy Terraform-managed infrastructure for specified environment
	@echo "$(RED)Destroying $(ENV) environment infrastructure...$(RESET)"
	@./scripts/terraform-destroy.sh $(ENV)

validate: ## Validate Terraform configuration
	@echo "$(CYAN)Validating Terraform configuration...$(RESET)"
	@./scripts/terraform-validate.sh

format: ## Format Terraform files
	@echo "$(MAGENTA)Formatting Terraform files...$(RESET)"
	@terraform fmt -recursive .

lint: ## Run Terraform linting with tflint
	@echo "$(CYAN)Running Terraform linting...$(RESET)"
	@./scripts/terraform-lint.sh

clean: ## Clean temporary files and state backups
	@echo "$(YELLOW)Cleaning temporary files...$(RESET)"
	@./scripts/clean.sh

status: ## Show current Terraform state status
	@echo "$(BLUE)Terraform state status for $(ENV) environment:$(RESET)"
	@./scripts/terraform-status.sh $(ENV)

outputs: ## Show Terraform outputs for specified environment
	@echo "$(GREEN)Terraform outputs for $(ENV) environment:$(RESET)"
	@./scripts/terraform-outputs.sh $(ENV)

show-envs: ## Show all available environments and their configurations
	@echo "$(CYAN)Available environments and configurations:$(RESET)"
	@./scripts/show-environments.sh

# Environment-specific shortcuts
init-all: ## Initialize all environments
	@echo "$(BLUE)Initializing all environments...$(RESET)"
	@for env in $(ENVIRONMENTS); do \
		echo "$(YELLOW)Initializing $$env...$(RESET)"; \
		make init ENV=$$env; \
	done

plan-all: ## Plan all environments
	@echo "$(YELLOW)Planning all environments...$(RESET)"
	@for env in $(ENVIRONMENTS); do \
		echo "$(CYAN)Planning $$env...$(RESET)"; \
		make plan ENV=$$env; \
	done

validate-all: ## Validate all environment configurations
	@echo "$(CYAN)Validating all environments...$(RESET)"
	@for env in $(ENVIRONMENTS); do \
		echo "$(YELLOW)Validating $$env...$(RESET)"; \
		terraform validate -var-file="envs/$$env/terraform.tfvars"; \
	done

# Development shortcuts
dev-init: ## Initialize development environment
	@make init ENV=dev

dev-plan: ## Plan development environment
	@make plan ENV=dev

dev-apply: ## Apply development environment
	@make apply ENV=dev

dev-destroy: ## Destroy development environment
	@make destroy ENV=dev

# Test shortcuts
test-init: ## Initialize test environment
	@make init ENV=test

test-plan: ## Plan test environment
	@make plan ENV=test

test-apply: ## Apply test environment
	@make apply ENV=test

test-destroy: ## Destroy test environment
	@make destroy ENV=test

# Production shortcuts (with additional safety)
prod-init: ## Initialize production environment
	@make init ENV=prod

prod-plan: ## Plan production environment
	@make plan ENV=prod

prod-apply: ## Apply production environment (requires confirmation)
	@echo "$(RED)WARNING: You are about to apply changes to PRODUCTION!$(RESET)"
	@echo "$(YELLOW)Please confirm by typing 'yes':$(RESET)"
	@read -p "" confirm && [ "$$confirm" = "yes" ] || (echo "$(RED)Production apply cancelled.$(RESET)" && exit 1)
	@make apply ENV=prod

prod-destroy: ## Destroy production environment (requires confirmation)
	@echo "$(RED)WARNING: You are about to DESTROY PRODUCTION infrastructure!$(RESET)"
	@echo "$(YELLOW)Please confirm by typing 'DELETE-PRODUCTION':$(RESET)"
	@read -p "" confirm && [ "$$confirm" = "DELETE-PRODUCTION" ] || (echo "$(RED)Production destroy cancelled.$(RESET)" && exit 1)
	@make destroy ENV=prod

# Utility targets
check-env: ## Check if environment is valid
	@if [ "$(ENV)" != "dev" ] && [ "$(ENV)" != "test" ] && [ "$(ENV)" != "prod" ]; then \
		echo "$(RED)Error: Invalid environment '$(ENV)'. Valid environments are: $(ENVIRONMENTS)$(RESET)"; \
		exit 1; \
	fi

install-tools: ## Install required tools (terraform, tflint, etc.)
	@echo "$(CYAN)Installing required tools...$(RESET)"
	@./scripts/install-tools.sh

# Security and compliance
security-scan: ## Run security scan on Terraform code
	@echo "$(MAGENTA)Running security scan...$(RESET)"
	@./scripts/security-scan.sh

cost-estimate: ## Estimate costs for specified environment
	@echo "$(YELLOW)Estimating costs for $(ENV) environment...$(RESET)"
	@./scripts/cost-estimate.sh $(ENV)

# Backup and restore
backup-state: ## Backup Terraform state
	@echo "$(BLUE)Backing up Terraform state for $(ENV)...$(RESET)"
	@./scripts/backup-state.sh $(ENV)

restore-state: ## Restore Terraform state
	@echo "$(YELLOW)Restoring Terraform state for $(ENV)...$(RESET)"
	@./scripts/restore-state.sh $(ENV)

# Documentation
docs: ## Generate documentation
	@echo "$(CYAN)Generating documentation...$(RESET)"
	@./scripts/generate-docs.sh

# Version info
version: ## Show version information
	@echo "$(CYAN)Version Information:$(RESET)"
	@echo "$(WHITE)Terraform:$(RESET) $$(terraform version | head -n1)"
	@echo "$(WHITE)Project:$(RESET) $(PROJECT_NAME)"
	@echo "$(WHITE)Region:$(RESET) $(AWS_REGION)"
	@echo "$(WHITE)Environments:$(RESET) $(ENVIRONMENTS)"
