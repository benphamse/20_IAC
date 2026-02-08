#!/bin/bash
# Cleanup script to empty and delete S3 bucket with versioning enabled

set -e  # Exit on any error

BUCKET_NAME="tf-state-ogmn6xw0"

echo "=== S3 Bucket Cleanup Script ==="
echo "Cleaning up bucket: $BUCKET_NAME"
echo ""

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if bucket exists
bucket_exists() {
    aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null
}

check_aws_cli

# Check if bucket exists
if ! bucket_exists; then
    echo "Bucket $BUCKET_NAME does not exist or is not accessible."
    echo "Please check your AWS credentials and bucket name."
    exit 1
fi

echo "Step 1: Deleting all current object versions..."
objects=$(aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --query 'Contents[].Key' --output text 2>/dev/null || echo "")
if [[ -n "$objects" && "$objects" != "None" ]]; then
    echo "$objects" | while read -r key; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting object: $key"
            aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key"
        fi
    done
else
    echo "No current objects to delete."
fi

echo ""
echo "Step 2: Deleting all non-current object versions..."
versions=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query 'Versions[?IsLatest==`false`].[Key,VersionId]' --output text 2>/dev/null || echo "")
if [[ -n "$versions" && "$versions" != "None" ]]; then
    echo "$versions" | while read -r key version_id; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting version: $key ($version_id)"
            aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$version_id"
        fi
    done
else
    echo "No object versions to delete."
fi

echo ""
echo "Step 3: Deleting all delete markers..."
markers=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query 'DeleteMarkers[].[Key,VersionId]' --output text 2>/dev/null || echo "")
if [[ -n "$markers" && "$markers" != "None" ]]; then
    echo "$markers" | while read -r key version_id; do
        if [[ -n "$key" && "$key" != "None" ]]; then
            echo "Deleting delete marker: $key ($version_id)"
            aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$version_id"
        fi
    done
else
    echo "No delete markers to delete."
fi

echo ""
echo "Step 4: Verifying bucket is empty..."
remaining_objects=$(aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --query 'Contents' --output text 2>/dev/null || echo "None")
remaining_versions=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query 'Versions' --output text 2>/dev/null || echo "None")

if [[ "$remaining_objects" == "None" && "$remaining_versions" == "None" ]]; then
    echo "✅ Bucket is now empty!"
else
    echo "⚠️  Warning: Bucket may still contain some objects"
fi

echo ""
echo "Step 5: Now you can run 'terraform destroy' to delete the bucket"
echo ""
echo "=== Cleanup completed! ==="
