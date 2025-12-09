# =============================================================================
# RAINBOW ENVIRONMENT SETUP SCRIPT
# This script initializes the environment for the Rainbow project. It performs
# the following steps:
# 1. Determines the base directory of the project.
# 2. Restarts the required databases using Docker Compose.
# 3. Executes the necessary 'setup' commands for Authority, Consumer, and Provider.
# Usage: .\auto-setup.ps1
# =============================================================================

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# ----------------------------
# 1. Base Directory Calculation
# Base directory (two levels up from scripts/powershell)
# ----------------------------
$BASE_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# ----------------------------
# 2. Global Configuration & Module Validation
# ----------------------------
# Define the path to the main docker-compose file for core services
$DOCKER_COMPOSE_PATH = "$BASE_DIR\deployment\docker-compose.core.yaml"

Write-Host "=== Starting Rainbow environment setup ===" -ForegroundColor Green

# ----------------------------
# 3. Start and Wait for Databases
# ----------------------------
Write-Host ""
Write-Host "--- Restarting databases with Docker Compose ---" -ForegroundColor Yellow

# 'down -v' stops and removes containers, and removes associated volumes
Write-Host "Stopping and removing containers with volumes..."
docker-compose -f "$DOCKER_COMPOSE_PATH" down -v

# 'up -d' recreates and starts services in detached mode
Write-Host "Starting database services..."
docker-compose -f "$DOCKER_COMPOSE_PATH" up -d ds_core_provider_db ds_core_consumer_db ds_authority_db

Write-Host "Waiting 10 seconds for databases to stabilize..."
Start-Sleep -Seconds 10

# ----------------------------
# 4. Setup Databases
# ----------------------------
Write-Host ""
Write-Host "--- Setup databases ---" -ForegroundColor Yellow
docker-compose -f "$DOCKER_COMPOSE_PATH" up -d ds_core_provider_setup ds_core_consumer_setup ds_authority_setup

# ----------------------------
# Bye!
# ----------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "Setup completed successfully" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
