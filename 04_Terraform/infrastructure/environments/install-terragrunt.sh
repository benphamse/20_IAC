#!/usr/bin/env bash
# ============================================================================
# INSTALL TERRAGRUNT
# ============================================================================

set -e

TERRAGRUNT_VERSION="0.55.1"  # Update to latest version
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Convert arch
case $ARCH in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64|arm64)
    ARCH="arm64"
    ;;
esac

DOWNLOAD_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${OS}_${ARCH}"

echo "📥 Downloading Terragrunt v${TERRAGRUNT_VERSION} for ${OS}/${ARCH}..."
curl -Lo /tmp/terragrunt "$DOWNLOAD_URL"

echo "🔐 Making executable..."
chmod +x /tmp/terragrunt

echo "📦 Installing to /usr/local/bin..."
sudo mv /tmp/terragrunt /usr/local/bin/terragrunt

echo "✅ Terragrunt installed successfully!"
terragrunt --version
