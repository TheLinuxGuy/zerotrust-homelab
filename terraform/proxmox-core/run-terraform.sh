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

if [ -z "$proxmox_endpoint" ]; then
    echo "❌ Error: proxmox_endpoint not set in .env"
    exit 1
fi

if [ -z "$proxmox_api_token_id" ]; then
    echo "❌ Error: proxmox_api_token_id not set in .env"
    exit 1
fi

if [ -z "$proxmox_api_token_secret" ]; then
    echo "❌ Error: proxmox_api_token_secret not set in .env"
    exit 1
fi

if [ -z "$acme_account_email" ]; then
    echo "❌ Error: acme_account_email not set in .env"
    exit 1
fi

if [ -z "$cloudflare_api_token" ]; then
    echo "❌ Error: cloudflare_api_token not set in .env"
    exit 1
fi

if [ -z "$proxmox_root_password" ]; then
    echo "❌ Error: proxmox_root_password not set in .env"
    exit 1
fi

echo "✅ Environment variables loaded successfully"

# Build terraform command with subcommand first, then -var flags
SUBCOMMAND="$1"
shift  # Remove the subcommand from arguments

TERRAFORM_CMD="terraform $SUBCOMMAND"

# Add -var flags for sensitive variables if they exist
if [ -n "$proxmox_endpoint" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"proxmox_endpoint=$proxmox_endpoint\""
fi


if [ -n "$proxmox_api_token_id" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"proxmox_api_token_id=$proxmox_api_token_id\""
fi

if [ -n "$proxmox_api_token_secret" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"proxmox_api_token_secret=$proxmox_api_token_secret\""
fi

if [ -n "$acme_account_email" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"acme_account_email=$acme_account_email\""
fi

if [ -n "$cloudflare_api_token" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"cloudflare_api_token=$cloudflare_api_token\""
fi

if [ -n "$cloudflare_zone_id" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"cloudflare_zone_id=$cloudflare_zone_id\""
fi

if [ -n "$proxmox_root_password" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -var=\"proxmox_root_password=$proxmox_root_password\""
fi

# Add the remaining arguments
# Add -auto-approve for apply command
if [ "$SUBCOMMAND" = "apply" ]; then
    TERRAFORM_CMD="$TERRAFORM_CMD -auto-approve"
fi

TERRAFORM_CMD="$TERRAFORM_CMD $@"

echo "🚀 Running: $TERRAFORM_CMD"

# Run terraform with the constructed command
eval "$TERRAFORM_CMD"