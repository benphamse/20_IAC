#!/bin/bash
# Backend setup script for Terraform state management

set -e  # Exit on any error

echo "=== Terraform Backend Setup for Day1 ==="
echo ""

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed or not in PATH"
        exit 1
    fi
}

# Function to cleanup existing bucket if needed
cleanup_existing_bucket() {
    local bucket_name="$1"
    echo "Cleaning up existing bucket: $bucket_name"

    # Check if bucket exists before trying to clean it
    if ! aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        echo "Bucket $bucket_name does not exist, skipping cleanup."
        return 0
    fi

    # Delete all current objects
    echo "Deleting current objects..."
    aws s3api list-objects-v2 --bucket "$bucket_name" --query 'Contents[].Key' --output text | \
    while read -r key; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting object: $key"
            aws s3api delete-object --bucket "$bucket_name" --key "$key"
        fi
    done

    # Delete all non-current versions
    echo "Deleting object versions..."
    aws s3api list-object-versions --bucket "$bucket_name" --query 'Versions[?IsLatest==`false`].[Key,VersionId]' --output text | \
    while read -r key version_id; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting version: $key ($version_id)"
            aws s3api delete-object --bucket "$bucket_name" --key "$key" --version-id "$version_id"
        fi
    done

    # Delete all delete markers
    echo "Deleting delete markers..."
    aws s3api list-object-versions --bucket "$bucket_name" --query 'DeleteMarkers[].[Key,VersionId]' --output text | \
    while read -r key version_id; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting delete marker: $key ($version_id)"
            aws s3api delete-object --bucket "$bucket_name" --key "$key" --version-id "$version_id"
        fi
    done

    echo "Bucket cleanup completed."
}

# Check prerequisites
check_aws_cli

# Check if we need to clean up existing bucket and backup state.tf
if [[ -f "state.tf" ]]; then
    EXISTING_BUCKET=$(grep 'bucket.*=' state.tf | sed 's/.*bucket.*=.*"\(.*\)".*/\1/')
    if [[ -n "$EXISTING_BUCKET" ]]; then
        echo "Found existing bucket in state.tf: $EXISTING_BUCKET"
        read -p "Do you want to clean up the existing bucket? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup_existing_bucket "$EXISTING_BUCKET"
        fi
    fi

    # Backup and temporarily remove state.tf to avoid backend initialization issues
    echo "Backing up state.tf and removing backend configuration temporarily..."
    cp state.tf state.tf.backup
    rm state.tf
fi

# Step 1: Initialize and create the backend infrastructure WITHOUT backend configuration
echo "Step 1: Creating S3 bucket and DynamoDB table for state management..."
terraform init
terraform plan -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_lock
terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_lock -auto-approve

# Step 2: Get the bucket name and DynamoDB table name
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name 2>/dev/null || echo "")

if [[ -z "$BUCKET_NAME" || -z "$DYNAMODB_TABLE" ]]; then
    echo "Error: Could not retrieve bucket name or DynamoDB table name from Terraform outputs"
    echo "Please check your Terraform configuration and try again."
    exit 1
fi

echo ""
echo "Backend infrastructure created:"
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Step 3: Create state.tf with the correct bucket name
echo "Step 3: Creating state.tf with the created bucket name..."
cat > state.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "day1/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "default"
    encrypt        = true
    dynamodb_table = "$DYNAMODB_TABLE"
    use_lockfile   = true
  }
}
EOF

echo "Created state.tf with backend configuration"
echo ""

# Step 4: Migrate state to S3 backend
echo "Step 4: Migrating state to S3 backend..."
terraform init -migrate-state

echo ""
echo "=== Backend setup completed successfully! ==="
echo "Your Terraform state is now stored in S3 with DynamoDB locking enabled."
echo ""
echo "Backend Configuration:"
echo "- S3 Bucket: $BUCKET_NAME"
echo "- DynamoDB Table: $DYNAMODB_TABLE"
echo "- Region: ap-southeast-1"
echo "- Encryption: Enabled"
echo "- State Locking: Enabled (S3 + DynamoDB)"
echo ""
echo "Next steps:"
echo "1. You can now run 'terraform plan' and 'terraform apply' normally"
echo "2. Your state will be automatically stored in S3"
echo "3. State locking will prevent concurrent modifications"
echo "4. To destroy everything later, run 'terraform destroy'"