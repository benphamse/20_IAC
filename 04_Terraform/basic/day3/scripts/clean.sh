#!/bin/bash
# Clean Script - Remove temporary files and backups
# Usage: ./clean.sh

# Source common functions
source "$(dirname "$0")/common.sh"

# Get directories
get_directories
cd "$PROJECT_ROOT"

# Clean temporary files
clean_temp_files() {
    log_info "Cleaning temporary files..."

    # Remove plan files
    find . -name "*.tfplan" -type f -delete 2>/dev/null || true

    # Remove crash logs
    find . -name "crash.log" -type f -delete 2>/dev/null || true

    # Remove override files
    find . -name "override.tf" -type f -delete 2>/dev/null || true
    find . -name "override.tf.json" -type f -delete 2>/dev/null || true

    # Remove .terraform.lock.hcl.backup files
    find . -name ".terraform.lock.hcl.backup" -type f -delete 2>/dev/null || true

    log_success "Temporary files cleaned"
}

# Clean backup files (optional)
clean_backup_files() {
    print_line
    log_warning "Found state backup files:"
    find . -name "terraform.tfstate.backup" -type f 2>/dev/null || echo "   No backup files found"

    print_line
    read -p "Do you want to remove state backup files? (y/N): " remove_backups

    if [[ "$remove_backups" =~ ^[Yy]$ ]]; then
        find . -name "terraform.tfstate.backup" -type f -delete 2>/dev/null || true
        log_success "Backup files removed"
    else
        log_info "Backup files preserved"
    fi
}

# Show cleanup summary
show_cleanup_summary() {
    log_info "Cleanup completed successfully!"
    print_line
    echo "Cleaned items:"
    echo "  ✓ Terraform plan files (*.tfplan)"
    echo "  ✓ Crash logs (crash.log)"
    echo "  ✓ Override files (override.tf*)"
    echo "  ✓ Lock backup files"
}

# Main function
main() {
    log_header "🧹 Starting cleanup process..."
    print_separator

    clean_temp_files
    clean_backup_files
    show_cleanup_summary
}

main "$@"
