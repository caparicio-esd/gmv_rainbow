#!/bin/bash
set -euo pipefail

# -----------------------------------------------------------------------------
# RAINBOW SERVICE START SCRIPT
# This script manages the full startup of the Rainbow environment:
# 1. Determines the base directory of the project.
# 2. Starts necessary applications using Docker Compose.
# -----------------------------------------------------------------------------

# ----------------------------
# 1. Base Directory Calculation
# Base directory (two levels up from scripts/bash, assuming script location)
# ----------------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)/../.."


# ----------------------------
# 2. Stop Applications
# ----------------------------
echo "Starting databases with Docker Compose..."
# Stop the containers.
DOCKER_COMPOSE_PATH="$BASE_DIR/deployment/docker-compose.core.yaml"
docker-compose -f "$DOCKER_COMPOSE_PATH" down  ds_core_provider ds_core_consumer ds_authority
echo "Waiting 3 seconds for applications to be killed..."
sleep 3

echo "Rainbow services stopped"
