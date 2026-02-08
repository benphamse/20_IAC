#!/bin/bash
# Terraform Status Script
# Usage: ./terraform-status.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Initialize common setup
init_common "${1:-dev}"

# Show infrastructure status
show_infrastructure_status() {
    log_header "📊 Infrastructure Status for $ENV Environment"
    print_separator

    # Check if Terraform is initialized
    if [[ -d ".terraform" ]]; then
        log_success "✓ Terraform initialized"
    else
        log_warning "✗ Terraform not initialized (run 'make init ENV=$ENV')"
    fi

    # Check if state file exists
    if [[ -f "terraform.tfstate" ]]; then
        log_success "✓ State file exists"

        # Show resource count
        if command_exists jq && terraform show -json > /dev/null 2>&1; then
            local resource_count=$(terraform show -json | jq -r '.values.root_module.resources | length' 2>/dev/null || echo "0")
            echo "   📦 Resources deployed: $resource_count"
        fi

        # Show last modified
        local last_modified=$(stat -c %y terraform.tfstate 2>/dev/null || echo "Unknown")
        echo "   🕒 Last modified: $last_modified"

    else
        log_warning "✗ No state file found (infrastructure not deployed)"
    fi

    # Check plan files
    local plan_file="${ENV}.tfplan"
    if [[ -f "$plan_file" ]]; then
        log_info "📋 Plan file exists: $plan_file"
    fi

    # Check configuration file
    log_success "✓ Configuration file: $TFVARS_FILE"
}

# Show AWS resources (if deployed)
show_aws_resources() {
    if [[ -f "terraform.tfstate" ]] && terraform show -json > /dev/null 2>&1; then
        print_line
        log_header "☁️  AWS Resources Summary:"

        # Try to get some basic info
        if terraform output > /dev/null 2>&1; then
            if terraform output -raw vpc_id > /dev/null 2>&1; then
                local vpc_id=$(terraform output -raw vpc_id)
                echo "   🏗️  VPC: $vpc_id"
            fi

            if terraform output -raw load_balancer_dns_name > /dev/null 2>&1; then
                local lb_dns=$(terraform output -raw load_balancer_dns_name)
                echo "   🔗 Load Balancer: $lb_dns"
            fi
        fi
    fi
}

# Show available actions
show_available_actions() {
    print_line
    log_header "🚀 Available Actions:"
    echo "   make plan ENV=$ENV      # Plan changes"
    echo "   make apply ENV=$ENV     # Apply changes"
    echo "   make outputs ENV=$ENV   # Show outputs"
    echo "   make destroy ENV=$ENV   # Destroy infrastructure"
}

# Main function
main() {
    show_env_info
    print_separator

    show_infrastructure_status
    show_aws_resources
    show_available_actions
}

main "$@"
