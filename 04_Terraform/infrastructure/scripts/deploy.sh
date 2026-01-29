#!/bin/bash

# Deploy script for Terraform backend setup and environment deployment
# Usage: ./deploy.sh [setup|dev|prod|all]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_SETUP_DIR="$PROJECT_ROOT/../backend-setup"
ENVIRONMENTS_DIR="$PROJECT_ROOT/../environments"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform >= 1.5.0"
        exit 1
    fi
    
    local version=$(terraform version -json | jq -r '.terraform_version')
    log_info "Using Terraform version: $version"
}

# Check if AWS CLI is configured
check_aws() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure'"
        exit 1
    fi
    
    local identity=$(aws sts get-caller-identity --query 'Arn' --output text)
    log_info "Using AWS identity: $identity"
}

# Setup backend infrastructure
setup_backend() {
    log_info "Setting up backend infrastructure..."
    
    cd "$BACKEND_SETUP_DIR"
    
    # Initialize terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan changes
    log_info "Planning backend infrastructure..."
    terraform plan -out=tfplan
    
    # Apply changes
    log_info "Applying backend infrastructure..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    log_success "Backend infrastructure setup completed!"
    
    # Display backend configurations
    echo ""
    log_info "Backend configurations:"
    echo ""
    echo "=== Development Backend Config ==="
    terraform output -raw dev_backend_config
    echo ""
    echo "=== Production Backend Config ==="
    terraform output -raw prod_backend_config
    echo ""
    
    # Update backend.hcl files
    update_backend_configs
}

# Update backend.hcl files with actual values
update_backend_configs() {
    log_info "Updating backend.hcl files..."
    
    cd "$BACKEND_SETUP_DIR"
    
    # Update dev backend.hcl
    terraform output -raw dev_backend_config > "$ENVIRONMENTS_DIR/dev/backend.hcl"
    log_success "Updated dev/backend.hcl"
    
    # Update prod backend.hcl
    terraform output -raw prod_backend_config > "$ENVIRONMENTS_DIR/prod/backend.hcl"
    log_success "Updated prod/backend.hcl"
}

# Deploy environment
deploy_environment() {
    local env=$1
    log_info "Deploying $env environment..."
    
    if [[ ! -d "$ENVIRONMENTS_DIR/$env" ]]; then
        log_error "Environment directory $env does not exist"
        exit 1
    fi
    
    cd "$ENVIRONMENTS_DIR/$env"
    
    # Check if backend.hcl exists
    if [[ ! -f "backend.hcl" ]]; then
        log_error "backend.hcl not found. Please run setup first."
        exit 1
    fi
    
    # Initialize with backend configuration
    log_info "Initializing Terraform with remote backend..."
    terraform init -backend-config=backend.hcl
    
    # Plan changes
    log_info "Planning $env environment..."
    terraform plan -out=tfplan
    
    # Apply changes
    log_info "Applying $env environment..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    log_success "$env environment deployed successfully!"
}

# Main deployment function
main() {
    local action=${1:-"help"}
    
    case $action in
        "setup")
            log_info "Starting backend setup..."
            check_terraform
            check_aws
            setup_backend
            ;;
        "dev")
            log_info "Deploying development environment..."
            check_terraform
            check_aws
            deploy_environment "dev"
            ;;
        "prod")
            log_info "Deploying production environment..."
            check_terraform
            check_aws
            deploy_environment "prod"
            ;;
        "all")
            log_info "Deploying all environments..."
            check_terraform
            check_aws
            setup_backend
            deploy_environment "dev"
            deploy_environment "prod"
            ;;
        "help"|*)
            echo "Usage: $0 [setup|dev|prod|all]"
            echo ""
            echo "Commands:"
            echo "  setup  - Setup backend infrastructure (S3 + DynamoDB)"
            echo "  dev    - Deploy development environment"
            echo "  prod   - Deploy production environment"
            echo "  all    - Setup backend and deploy all environments"
            echo "  help   - Show this help message"
            echo ""
            echo "Prerequisites:"
            echo "  - Terraform >= 1.5.0"
            echo "  - AWS CLI configured"
            echo "  - jq (for JSON processing)"
            exit 0
            ;;
    esac
}

# Run main function
main "$@"
ACTION=$2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate inputs
if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    print_error "Usage: $0 <environment> <action>"
    print_info "Available environments: dev, staging, prod"
    print_info "Available actions: init, plan, apply, destroy, validate, fmt"
    exit 1
fi

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    print_error "Environment directory not found: $ENV_DIR"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
    print_error "terraform.tfvars not found in $ENV_DIR"
    exit 1
fi

print_info "Working with environment: $ENVIRONMENT"
print_info "Action: $ACTION"
print_info "Directory: $ENV_DIR"

cd "$ENV_DIR"

case $ACTION in
    "init")
        print_info "Initializing Terraform..."
        terraform init -upgrade
        print_success "Terraform initialized successfully"
        ;;
    
    "validate")
        print_info "Validating Terraform configuration..."
        terraform validate
        print_success "Terraform configuration is valid"
        ;;
    
    "fmt")
        print_info "Formatting Terraform files..."
        terraform fmt -recursive "$PROJECT_ROOT"
        print_success "Terraform files formatted"
        ;;
    
    "plan")
        print_info "Creating Terraform execution plan..."
        terraform plan -var-file="terraform.tfvars" -out="tfplan"
        print_success "Terraform plan created successfully"
        ;;
    
    "apply")
        print_warning "This will apply changes to $ENVIRONMENT environment"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Applying Terraform changes..."
            if [ -f "tfplan" ]; then
                terraform apply "tfplan"
            else
                terraform apply -var-file="terraform.tfvars" -auto-approve
            fi
            print_success "Terraform changes applied successfully"
        else
            print_info "Operation cancelled"
        fi
        ;;
    
    "destroy")
        print_warning "This will DESTROY all resources in $ENVIRONMENT environment"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Destroying Terraform resources..."
            terraform destroy -var-file="terraform.tfvars" -auto-approve
            print_success "Terraform resources destroyed successfully"
        else
            print_info "Operation cancelled"
        fi
        ;;
    
    "output")
        print_info "Showing Terraform outputs..."
        terraform output
        ;;
    
    *)
        print_error "Unknown action: $ACTION"
        print_info "Available actions: init, plan, apply, destroy, validate, fmt, output"
        exit 1
        ;;
esac

print_success "Script completed successfully"
