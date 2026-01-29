#!/bin/bash
# Terraform Destroy Script
# Usage: ./terraform-destroy.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Initialize common setup
init_common "${1:-dev}"

# Destroy infrastructure
destroy_infrastructure() {
    log_info "Destroying infrastructure for $ENV environment..."

    if terraform destroy -var-file="$TFVARS_FILE" -auto-approve; then
        log_success "Infrastructure destroyed successfully for $ENV environment"
    else
        log_error "Failed to destroy infrastructure"
        exit 1
    fi
}

# Main function
main() {
    show_env_info
    print_separator

    # Safety confirmation with enhanced protection for production
    production_safety_check "$ENV" "destroy"

    check_terraform_initialized
    destroy_infrastructure
    cleanup_temp_files

    print_line
    log_success "All resources for $ENV environment have been destroyed!"
    log_warning "Remember to verify in AWS Console that all resources are removed"
}

main "$@"
