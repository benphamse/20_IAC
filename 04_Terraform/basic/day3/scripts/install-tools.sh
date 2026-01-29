#!/bin/bash
# Install Tools Script
# Usage: ./install-tools.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Terraform
install_terraform() {
    if command_exists terraform; then
        local version=$(terraform version | head -n1)
        log_success "Terraform already installed: $version"
        return 0
    fi

    log_info "Installing Terraform..."

    # Download and install Terraform
    local tf_version="1.5.0"
    local tf_url="https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip"

    curl -LO "$tf_url"
    unzip "terraform_${tf_version}_linux_amd64.zip"
    sudo mv terraform /usr/local/bin/
    rm "terraform_${tf_version}_linux_amd64.zip"

    log_success "Terraform installed successfully"
}

# Install AWS CLI
install_aws_cli() {
    if command_exists aws; then
        local version=$(aws --version)
        log_success "AWS CLI already installed: $version"
        return 0
    fi

    log_info "Installing AWS CLI..."

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip

    log_success "AWS CLI installed successfully"
}

# Install jq
install_jq() {
    if command_exists jq; then
        local version=$(jq --version)
        log_success "jq already installed: $version"
        return 0
    fi

    log_info "Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
    log_success "jq installed successfully"
}

# Install make
install_make() {
    if command_exists make; then
        local version=$(make --version | head -n1)
        log_success "make already installed: $version"
        return 0
    fi

    log_info "Installing make..."
    sudo apt-get update && sudo apt-get install -y build-essential
    log_success "make installed successfully"
}

# Main
main() {
    log_info "Installing required tools for Terraform development..."

    install_make
    install_terraform
    install_aws_cli
    install_jq

    echo ""
    log_success "🎉 All tools installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Configure AWS credentials: aws configure"
    echo "  2. Initialize project: make init ENV=dev"
    echo "  3. Plan deployment: make plan ENV=dev"
}

main "$@"
