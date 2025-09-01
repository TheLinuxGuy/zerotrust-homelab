#!/bin/bash

# Terraform Runner with Environment Variables
# This script loads the .env file and runs terraform commands
# Usage: ./run-terraform.sh <terraform-command> [args...]

set -e  # Exit on any error

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create .env file with your local credentials:"
    echo "export proxmox_endpoint=\"https://your-proxmox:8006/api2/json\""
    echo "export proxmox_api_token_id=\"your-token-id\""
    echo "export proxmox_api_token_secret=\"your-token-secret\""
    exit 1
fi

# Load environment variables
echo "🔐 Loading environment variables from .env..."
set -a  # Export all variables
source .env
set +a

# Verify required variables are set
if [ -z "$proxmox_api_token_secret" ]; then
    echo "❌ Error: proxmox_api_token_secret not set in .env"
    exit 1
fi

if [ -z "$proxmox_api_token_id" ]; then
    echo "❌ Error: proxmox_api_token_id not set in .env"
    exit 1
fi

if [ -z "$proxmox_endpoint" ]; then
    echo "❌ Error: proxmox_endpoint not set in .env"
    exit 1
fi

echo "✅ Environment variables loaded successfully"
echo "🚀 Running: terraform $@"

# Run terraform with all passed arguments
terraform "$@"
