#!/bin/bash
# Terraform Plan Script
# Usage: ./terraform-plan.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Initialize common setup
init_common "${1:-dev}"

# Run terraform plan
run_plan() {
    local plan_file="${ENV}.tfplan"

    log_info "Creating execution plan for $ENV environment..."

    if terraform plan -var-file="$TFVARS_FILE" -out="$plan_file"; then
        log_success "Plan created successfully: $plan_file"
        print_line
        echo "Plan summary saved to: $plan_file"
        echo "To apply: make apply ENV=$ENV"
    else
        log_error "Failed to create plan"
        exit 1
    fi
}

# Main function
main() {
    show_env_info
    print_separator

    check_terraform_initialized
    run_plan
}

main "$@"
