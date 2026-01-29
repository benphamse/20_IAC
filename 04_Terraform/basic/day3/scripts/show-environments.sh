#!/bin/bash
# Show Environment Configurations Script
# Usage: ./show-environments.sh

# Source common functions
source "$(dirname "$0")/common.sh"

# Get directories
get_directories
cd "$PROJECT_ROOT"

# Show environment details
show_environment() {
    local env=$1
    local tfvars_file="envs/$env/terraform.tfvars"

    if [[ -f "$tfvars_file" ]]; then
        print_line
        log_header "📁 $env Environment Configuration:"
        echo "   File: envs/$env/terraform.tfvars"

        # Parse and display key configurations
        if grep -q "instance_type" "$tfvars_file"; then
            local instance_type=$(grep "instance_type" "$tfvars_file" | cut -d'"' -f2)
            echo "   Instance Type: $instance_type"
        fi

        if grep -q "vpc_cidr" "$tfvars_file"; then
            local vpc_cidr=$(grep "vpc_cidr" "$tfvars_file" | cut -d'"' -f2)
            echo "   VPC CIDR: $vpc_cidr"
        fi

        if grep -q "environment" "$tfvars_file"; then
            local environment=$(grep "environment" "$tfvars_file" | cut -d'"' -f2)
            echo "   Environment: $environment"
        fi

        if grep -q "project_name" "$tfvars_file"; then
            local project_name=$(grep "project_name" "$tfvars_file" | cut -d'"' -f2)
            echo "   Project Name: $project_name"
        fi

        if grep -q "owner" "$tfvars_file"; then
            local owner=$(grep "owner" "$tfvars_file" | cut -d'"' -f2)
            echo "   Owner: $owner"
        fi

        # Show usage commands
        print_line
        echo "   Quick Commands:"
        echo "     make init ENV=$env     # Initialize"
        echo "     make plan ENV=$env     # Plan deployment"
        echo "     make apply ENV=$env    # Deploy"
        echo "     make destroy ENV=$env  # Destroy"
    else
        print_line
        log_warning "❌ $env: Configuration file not found"
    fi
}

# Show project structure
show_project_structure() {
    print_line
    log_header "📊 Project Structure:"
    echo "   Root: $(basename "$PROJECT_ROOT")"
    echo "   Modules: $(ls -1 modules/ 2>/dev/null | wc -l) modules available"
    echo "   Scripts: $(ls -1 scripts/ 2>/dev/null | wc -l) utility scripts"
}

# Show quick start guide
show_quick_start() {
    print_line
    log_header "🚀 Quick Start:"
    echo "   make help              # Show all commands"
    echo "   make init-all          # Initialize all environments"
    echo "   make validate          # Validate configurations"
    echo "   make dev-apply         # Deploy to development"
}

# Main function
main() {
    log_header "🌍 Available Terraform Environments"
    print_separator

    for env in "${VALID_ENVIRONMENTS[@]}"; do
        show_environment "$env"
    done

    show_project_structure
    show_quick_start
}

main "$@"
