#!/bin/bash
# Quick Setup Script
# Usage: ./quick-setup.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_header() { echo -e "${CYAN}$1${NC}"; }

# Main setup
main() {
    log_header "🚀 Terraform Project Quick Setup"
    echo "================================="

    log_info "Setting up the Terraform multi-environment project..."

    # Make scripts executable
    chmod +x scripts/*.sh
    log_success "✓ Scripts made executable"

    # Show project structure
    echo ""
    log_header "📁 Project Structure:"
    echo "   ├── main.tf              # Main configuration"
    echo "   ├── variables.tf         # Global variables"
    echo "   ├── outputs.tf           # Global outputs"
    echo "   ├── Makefile            # Build automation"
    echo "   ├── envs/               # Environment configs"
    echo "   │   ├── dev/            # Development"
    echo "   │   ├── test/           # Testing"
    echo "   │   └── prod/           # Production"
    echo "   ├── modules/            # Terraform modules"
    echo "   │   ├── networking/     # VPC, subnets"
    echo "   │   ├── security/       # Security groups"
    echo "   │   ├── compute/        # EC2 instances"
    echo "   │   └── load-balancing/ # ALB"
    echo "   └── scripts/            # Automation scripts"

    echo ""
    log_header "⚡ Quick Commands:"
    echo "   make help               # Show all commands"
    echo "   make show-envs         # Show environment configs"
    echo "   make validate          # Validate all configurations"
    echo "   make dev-apply         # Deploy to development"
    echo "   make test-apply        # Deploy to test"
    echo "   make prod-apply        # Deploy to production (with safety)"

    echo ""
    log_header "🔧 Next Steps:"
    echo "   1. Configure AWS credentials: aws configure"
    echo "   2. Review environments: make show-envs"
    echo "   3. Validate config: make validate"
    echo "   4. Deploy to dev: make dev-apply"

    echo ""
    log_success "🎉 Setup completed! Your Terraform project is ready to use."
}

main "$@"
