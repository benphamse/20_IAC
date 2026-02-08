#!/bin/bash
# Terraform Apply Script
# Usage: ./terraform-apply.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Initialize common setup
init_common "${1:-dev}"

# Apply terraform configuration
apply_terraform() {
    local plan_file="${ENV}.tfplan"

    log_info "Starting infrastructure deployment for $ENV environment"

    # Check if plan file exists
    if [[ -f "$plan_file" ]]; then
        log_info "Applying existing plan: $plan_file"
        if terraform apply "$plan_file"; then
            log_success "Infrastructure deployed successfully for $ENV environment"
            rm -f "$plan_file"  # Clean up plan file
        else
            log_error "Failed to apply infrastructure"
            exit 1
        fi
    else
        log_warning "No plan file found. Creating and applying directly..."
        if terraform apply -var-file="$TFVARS_FILE" -auto-approve; then
            log_success "Infrastructure deployed successfully for $ENV environment"
        else
            log_error "Failed to apply infrastructure"
            exit 1
        fi
    fi
}

# Show outputs
show_outputs() {
    log_info "Deployment outputs:"
    terraform output
}

# Main function
main() {
    show_env_info
    print_separator

    # Production safety check
    production_safety_check "$ENV" "apply"

    # Apply terraform
    apply_terraform

    # Show outputs
    print_line
    show_outputs

    print_line
    log_success "Deployment completed for $ENV environment!"
    echo "Access your application using the load balancer DNS name shown above."
}

main "$@"
