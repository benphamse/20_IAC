#!/bin/bash
# Terraform Validate Script
# Usage: ./terraform-validate.sh

# Source common functions
source "$(dirname "$0")/common.sh"

# Get directories
get_directories
cd "$PROJECT_ROOT"

# Validate main configuration
validate_main() {
    log_info "Validating main Terraform configuration..."

    if terraform validate; then
        log_success "Main configuration is valid"
        return 0
    else
        log_error "Main configuration validation failed"
        return 1
    fi
}

# Validate modules
validate_modules() {
    log_info "Validating Terraform modules..."

    local modules=("networking" "security" "compute" "load-balancing")
    local errors=0

    for module in "${modules[@]}"; do
        local module_path="modules/$module"
        if [[ -d "$module_path" ]]; then
            log_info "Validating module: $module"
            cd "$module_path"
            if terraform validate; then
                log_success "Module $module is valid"
            else
                log_error "Module $module validation failed"
                ((errors++))
            fi
            cd "$PROJECT_ROOT"
        else
            log_warning "Module directory not found: $module_path"
        fi
    done

    return $errors
}

# Validate environment configs
validate_environments() {
    log_info "Validating environment configurations..."

    local errors=0

    for env in "${VALID_ENVIRONMENTS[@]}"; do
        local tfvars_file="envs/$env/terraform.tfvars"
        if [[ -f "$tfvars_file" ]]; then
            log_info "Validating $env environment configuration"
            if terraform validate -var-file="$tfvars_file"; then
                log_success "Environment $env configuration is valid"
            else
                log_error "Environment $env configuration validation failed"
                ((errors++))
            fi
        else
            log_warning "Configuration file not found: $tfvars_file"
        fi
    done

    return $errors
}

# Check Terraform format
check_format() {
    log_info "Checking Terraform code formatting..."

    if terraform fmt -check -recursive; then
        log_success "All files are properly formatted"
        return 0
    else
        log_warning "Some files need formatting. Run 'make format' to fix"
        return 1
    fi
}

# Main function
main() {
    log_header "🔍 Starting comprehensive Terraform validation"
    print_separator

    local total_errors=0

    # Run validations
    validate_main || ((total_errors++))
    validate_modules || ((total_errors += $?))
    validate_environments || ((total_errors += $?))
    check_format || ((total_errors++))

    print_line
    if [[ $total_errors -eq 0 ]]; then
        log_success "🎉 All validations passed successfully!"
        echo "Your Terraform configuration is ready for deployment."
    else
        log_error "❌ Validation completed with $total_errors error(s)"
        echo "Please fix the issues above before proceeding."
        exit 1
    fi
}

main "$@"
