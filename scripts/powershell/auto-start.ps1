# =============================================================================
# RAINBOW SERVICE START SCRIPT
# This script manages the full startup of the Rainbow environment:
# 1. Determines the base directory of the project.
# 2. Starts necessary applications using Docker Compose.
# =============================================================================

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# ----------------------------
# 1. Base Directory Calculation
# Base directory (two levels up from scripts/powershell)
# ----------------------------
$BASE_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# ----------------------------
# 2. Start Applications
# ----------------------------
Write-Host "Starting databases with Docker Compose..." -ForegroundColor Yellow

# Starts the containers and runs them in detached (background) mode.
$DOCKER_COMPOSE_PATH = "$BASE_DIR\deployment\docker-compose.core.yaml"
docker-compose -f "$DOCKER_COMPOSE_PATH" up -d ds_core_provider1 ds_core_provider2 ds_core_consumer ds_authority

Write-Host "Waiting 10 seconds for applications to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "Rainbow services started. Check the processes for live logs" -ForegroundColor Green
