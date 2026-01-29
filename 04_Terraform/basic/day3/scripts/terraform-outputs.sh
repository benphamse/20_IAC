#!/bin/bash
# Terraform Outputs Script
# Usage: ./terraform-outputs.sh <environment>

# Source common functions
source "$(dirname "$0")/common.sh"

# Initialize common setup
init_common "${1:-dev}"

# Show outputs
show_terraform_outputs() {
    log_header "🔍 Terraform Outputs for $ENV Environment"
    print_separator

    # Check if state file exists
    if [[ ! -f "terraform.tfstate" ]]; then
        log_error "No Terraform state found. Run 'make apply ENV=$ENV' first."
        exit 1
    fi

    # Show all outputs in a formatted way
    if terraform output > /dev/null 2>&1; then
        print_line
        terraform output
        print_line

        # Extract and highlight important outputs
        log_header "🌐 Quick Access Information:"

        # Load balancer DNS
        if terraform output -raw load_balancer_dns_name > /dev/null 2>&1; then
            local lb_dns=$(terraform output -raw load_balancer_dns_name)
            echo "   🔗 Application URL: http://$lb_dns"
        fi

        # VPC ID
        if terraform output -raw vpc_id > /dev/null 2>&1; then
            local vpc_id=$(terraform output -raw vpc_id)
            echo "   🏗️  VPC ID: $vpc_id"
        fi

        # Web server IPs
        if terraform output -raw web_server1_public_ip > /dev/null 2>&1; then
            local web1_ip=$(terraform output -raw web_server1_public_ip)
            echo "   🖥️  Web Server 1: $web1_ip"
        fi

        if terraform output -raw web_server2_public_ip > /dev/null 2>&1; then
            local web2_ip=$(terraform output -raw web_server2_public_ip)
            echo "   🖥️  Web Server 2: $web2_ip"
        fi

    else
        log_error "Failed to retrieve outputs"
        exit 1
    fi
}

# Show connection info
show_connection_info() {
    print_line
    log_header "🔗 Connection Information:"
    echo "   Environment: $ENV"
    echo "   Region: ap-southeast-1"
    if command_exists jq && terraform show -json > /dev/null 2>&1; then
        local resource_count=$(terraform show -json | jq -r '.values.root_module.resources | length' 2>/dev/null || echo "N/A")
        echo "   Status: $resource_count resources deployed"
    fi
}

# Main function
main() {
    show_env_info
    print_separator

    check_terraform_initialized
    show_terraform_outputs
    show_connection_info
}

main "$@"
