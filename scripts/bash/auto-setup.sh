#!/bin/bash
set -euo pipefail

# -----------------------------------------------------------------------------
# RAINBOW ENVIRONMENT SETUP SCRIPT
# This script initializes the environment for the Rainbow project. It performs
# the following steps:
# 1. Determines the base directory of the project.
# 2. Restarts the required databases using Docker Compose.
# 3. Executes the necessary 'setup' commands for Authority, Consumer, and Provider.
# Usage: ./rainbow_setup.sh [module_name] (e.g., ./rainbow_setup.sh core)
# -----------------------------------------------------------------------------

# ----------------------------
# 1. Base Directory Calculation
# Base directory (two levels up from scripts/bash, assuming script location)
# ----------------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/../.."

# ----------------------------
# 2. Global Configuration & Module Validation
# ----------------------------
# Define the path to the main docker-compose file for core services
DOCKER_COMPOSE_PATH="$BASE_DIR/deployment/docker-compose.core.yaml"

echo "=== Starting Rainbow environment setup ==="

# ----------------------------
# 3. Start and Wait for Databases
# ----------------------------
echo ""
echo "--- Restarting databases with Docker Compose ---"
# 'down -v' stops and removes containers, and removes associated volumes
docker-compose -f "$DOCKER_COMPOSE_PATH" down -v
# 'up -d' recreates and starts services in detached mode
docker-compose -f "$DOCKER_COMPOSE_PATH" up -d ds_core_provider1_db ds_core_provider2_db ds_core_consumer_db ds_authority_db
echo "Waiting 5 seconds for databases to stabilize..."
sleep 5


# ----------------------------
# 4. Setup Databases
# ----------------------------
echo ""
echo "--- Setup databases ---"
docker-compose -f "$DOCKER_COMPOSE_PATH" up -d ds_core_provider1_setup ds_core_provider2_setup ds_core_consumer_setup ds_authority_setup


# ----------------------------
# Bye!
# ----------------------------
echo ""
echo "================================================================"
echo "Setup completed successfully"
echo "================================================================"
