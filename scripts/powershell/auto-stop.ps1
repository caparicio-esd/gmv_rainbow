# -----------------------------------------------------------------------------
# RAINBOW SERVICE STOP SCRIPT (PowerShell)
# This script manages the shutdown of the Rainbow environment:
# 1. Determines the base directory of the project.
# 2. Stops necessary applications using Docker Compose.
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# ----------------------------
# 1. Base Directory Calculation
# Base directory (two levels up from scripts\bash, assuming script location)
# ----------------------------
$BASE_DIR = Resolve-Path (Join-Path $PSScriptRoot "..\..")

# ----------------------------
# 2. Stop Applications
# ----------------------------
Write-Host "Stopping databases with Docker Compose..."

$DOCKER_COMPOSE_PATH = Join-Path $BASE_DIR "deployment\docker-compose.core.yaml"

docker-compose -f $DOCKER_COMPOSE_PATH down ds_core_provider ds_core_consumer ds_authority

Write-Host "Waiting 3 seconds for applications to be killed..."
Start-Sleep -Seconds 3

Write-Host "Rainbow services stopped"
