#!/bin/bash
# Terraform Init Script
# Usage: ./terraform-init.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Get directories first (needed before init_common)
get_directories

# Basic validation without full init (since we're initializing)
ENV=${1:-$DEFAULT_ENV}
validate_environment "$ENV"
check_tfvars_file "$ENV"

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform for $ENV environment..."

    # Remove .terraform directory if exists (for clean init)
    if [[ -d ".terraform" ]]; then
        log_warning "Removing existing .terraform directory"
        rm -rf .terraform
    fi

    # Initialize
    if terraform init; then
        log_success "Terraform initialized successfully for $ENV environment"
    else
        log_error "Failed to initialize Terraform"
        exit 1
    fi
}

# Main function
main() {
    cd "$PROJECT_ROOT"

    show_env_info
    print_separator

    init_terraform

    print_line
    log_success "Terraform initialization completed for $ENV environment"
    print_line
    echo "Next steps:"
    echo "  make plan ENV=$ENV     # Plan the deployment"
    echo "  make apply ENV=$ENV    # Apply the configuration"
}

main "$@"
