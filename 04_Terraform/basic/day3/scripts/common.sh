#!/bin/bash
# Common functions and variables for Terraform scripts
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

# Exit on any error
set -e

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[0;37m'
export NC='\033[0m' # No Color

# Global variables
export VALID_ENVIRONMENTS=("dev" "test" "prod")
export DEFAULT_ENV="dev"

# Get script and project directories
get_directories() {
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
}

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

log_header() {
    echo -e "${CYAN}$1${NC}"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $1"
    fi
}

# Print separator line
print_separator() {
    echo "=================================================="
}

# Print empty line
print_line() {
    echo ""
}

# Environment validation
validate_environment() {
    local env=${1:-$DEFAULT_ENV}

    # Check if environment is in valid list
    local valid=false
    for valid_env in "${VALID_ENVIRONMENTS[@]}"; do
        if [[ "$env" == "$valid_env" ]]; then
            valid=true
            break
        fi
    done

    if [[ "$valid" == "false" ]]; then
        log_error "Invalid environment: $env"
        log_info "Valid environments are: ${VALID_ENVIRONMENTS[*]}"
        exit 1
    fi

    export ENV="$env"
    log_debug "Environment validated: $ENV"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
check_required_tools() {
    local missing_tools=()

    # Check terraform
    if ! command_exists terraform; then
        missing_tools+=("terraform")
    fi

    # Check aws cli (optional but recommended)
    if ! command_exists aws; then
        log_warning "AWS CLI not found - consider installing for better experience"
    fi

    # Check jq (optional)
    if ! command_exists jq; then
        log_warning "jq not found - some features may be limited"
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Run 'make install-tools' to install missing tools"
        exit 1
    fi
}

# Check if terraform is initialized
check_terraform_initialized() {
    if [[ ! -d "$PROJECT_ROOT/.terraform" ]]; then
        log_error "Terraform not initialized"
        log_info "Run 'make init ENV=$ENV' first"
        exit 1
    fi
}

# Check if tfvars file exists
check_tfvars_file() {
    local env=${1:-$ENV}
    local tfvars_file="$PROJECT_ROOT/envs/$env/terraform.tfvars"

    if [[ ! -f "$tfvars_file" ]]; then
        log_error "Configuration file not found: $tfvars_file"
        exit 1
    fi

    log_debug "Configuration file found: $tfvars_file"
    export TFVARS_FILE="$tfvars_file"
}

# Production safety check
production_safety_check() {
    local env=${1:-$ENV}
    local action=${2:-"deploy"}

    if [[ "$env" == "prod" ]]; then
        print_line
        log_warning "🚨 PRODUCTION $action WARNING 🚨"
        echo "You are about to $action PRODUCTION environment!"
        echo "This action will:"
        echo "  - Create or modify production resources"
        echo "  - May incur AWS costs"
        echo "  - Affect live users and services"
        print_line

        case $action in
            "deploy"|"apply")
                read -p "Type 'DEPLOY-TO-PRODUCTION' to confirm: " confirmation
                if [[ "$confirmation" != "DEPLOY-TO-PRODUCTION" ]]; then
                    log_error "Production deployment cancelled"
                    exit 1
                fi
                ;;
            "destroy")
                log_error "🚨 PRODUCTION DESTRUCTION WARNING 🚨"
                echo "You are about to DESTROY PRODUCTION infrastructure!"
                read -p "Type 'DESTROY-PRODUCTION' to confirm: " confirmation
                if [[ "$confirmation" != "DESTROY-PRODUCTION" ]]; then
                    log_error "Production destruction cancelled"
                    exit 1
                fi
                ;;
            *)
                read -p "Type 'CONFIRM-PRODUCTION' to proceed: " confirmation
                if [[ "$confirmation" != "CONFIRM-PRODUCTION" ]]; then
                    log_error "Production action cancelled"
                    exit 1
                fi
                ;;
        esac
    fi
}

# Show environment info
show_env_info() {
    local env=${1:-$ENV}
    log_info "Environment: $env"
    log_info "Project Root: $PROJECT_ROOT"
    log_info "Configuration: envs/$env/terraform.tfvars"
}

# Cleanup temporary files
cleanup_temp_files() {
    local env=${1:-$ENV}
    log_debug "Cleaning up temporary files for $env"

    # Remove plan files
    rm -f "$PROJECT_ROOT/${env}.tfplan"

    # Remove crash logs
    find "$PROJECT_ROOT" -name "crash.log" -type f -delete 2>/dev/null || true
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Script failed at line $line_number with exit code $exit_code"
    cleanup_temp_files
    exit $exit_code
}

# Set error trap
set_error_trap() {
    trap 'handle_error $LINENO' ERR
}

# Show script usage
show_usage() {
    local script_name=$(basename "${BASH_SOURCE[1]}")
    echo "Usage: $script_name <environment>"
    echo "Available environments: ${VALID_ENVIRONMENTS[*]}"
    echo "Example: $script_name dev"
}

# Initialize common setup
init_common() {
    local env=${1:-$DEFAULT_ENV}

    # Set error trap
    set_error_trap

    # Get directories
    get_directories

    # Validate environment
    validate_environment "$env"

    # Check required tools
    check_required_tools

    # Check tfvars file
    check_tfvars_file

    # Change to project root
    cd "$PROJECT_ROOT"

    log_debug "Common initialization completed"
}

# Export all functions for use in other scripts
export -f log_info log_success log_warning log_error log_header log_debug
export -f print_separator print_line validate_environment command_exists
export -f check_required_tools check_terraform_initialized check_tfvars_file
export -f production_safety_check show_env_info cleanup_temp_files
export -f handle_error set_error_trap show_usage init_common get_directories
