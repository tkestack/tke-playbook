#!/bin/bash

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "=== Working Directory: $SCRIPT_DIR ==="

# Destroy resources
echo "=== Starting Resource Destruction ==="
terraform destroy -auto-approve
