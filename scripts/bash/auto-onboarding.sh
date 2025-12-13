#!/bin/bash

# ==============================================================================
# Script de Auto-Onboarding (Versión Sincronizada con PowerShell Source-of-Truth)
# ==============================================================================
#
# Descripción:
#   Este script automatiza el proceso de Onboarding para wallets (A, C, P)
#   y la secuencia de intercambio de credenciales y acceso (OIDC4VCI y OIDC4VP).
#   Replica la lógica exacta del script 'auto-onboarding.ps1'.
#
# Requisitos:
#   - curl
#   - jq (para procesamiento y construcción de JSON)
#
# ==============================================================================

# --- 1. Definición de URLs (Entorno Local) ---
AuthorityUrl="http://127.0.0.1:1500"
ConsumerUrl="http://127.0.0.1:1100"
Provider1Url="http://127.0.0.1:1200"
Provider2Url="http://127.0.0.1:1800"

# --- Definición de URLs (Entorno Docker Interno) ---
# Estas URLs se envían dentro de los payloads JSON para que los contenedores
# se comuniquen entre sí.
AuthorityUrlFromDocker="http://host.docker.internal:1500"
ConsumerUrlFromDocker="http://host.docker.internal:1100"
Provider1UrlFromDocker="http://host.docker.internal:1200"
Provider2UrlFromDocker="http://host.docker.internal:1800"


# Fail-fast: Detener la ejecución inmediatamente si ocurre un error.
set -e

# --- Utility Function: invoke_curl_robust ---
# Función para ejecutar comandos curl con manejo de errores, logging claro
# y visualización del comando exacto antes de la ejecución.
#
# Argumentos:
#   1: Método HTTP (GET, POST)
#   2: URL
#   3: Cuerpo JSON (Opcional, dejar vacío "" si no aplica)
#   4: Mensaje de Log para contexto humano
function invoke_curl_robust {
    local method="$1"
    local url="$2"
    local body="$3"
    local log_message="$4"
    local output=""
    local curl_base_command="curl -s -X $method"
    local full_curl_command=""

    echo "" >&2
    echo "--- Executing step: $log_message ---" >&2
    echo "   URL: $url" >&2

    # Construcción del comando para visualización y ejecución
    if [[ -n "$body" ]]; then
        # Comando con payload JSON
        full_curl_command="$curl_base_command -H \"Content-Type: application/json\" -d '$body' $url"
    else
        # Comando simple
        full_curl_command="$curl_base_command $url"
    fi

    echo "   CMD: $full_curl_command" >&2

    # Ejecución del comando usando eval para respetar el entrecomillado del JSON
    output=$(eval "$full_curl_command")
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo "--- ERROR ($log_message): curl connection/command failed (Code: $exit_code) ---" >&2
        echo "--- Exiting script. ---" >&2
        exit 1
    fi

    # Verificar códigos de error HTTP dentro de la respuesta si es necesario
    # (Curl simple no falla en 404/500 sin el flag -f, pero aquí asumimos conexión exitosa a nivel TCP)
    
    echo "   STATUS: SUCCESS" >&2
    echo "---------------------------------------------------" >&2

    # Retornar el output por STDOUT para ser capturado o pipeado
    echo "$output"
}

# ==============================================================================
# 2. Secuencia de Onboarding y Procesamiento
# ==============================================================================

echo "Starting auto-onboarding script (Bash Port)..." >&2

# ----------------------------
# 2.1 - 2.3 Onboarding Authority / Consumer / Provider1 / Provider2
# ----------------------------
# PowerShell: Invoke-CurlJson ... -ParseJson:$false
invoke_curl_robust "POST" "$AuthorityUrl/api/v1/wallet/onboard" "" "1. Onboarding Authority (A)"
invoke_curl_robust "POST" "$ConsumerUrl/api/v1/wallet/onboard" "" "2. Onboarding Consumer (C)"
invoke_curl_robust "POST" "$Provider1Url/api/v1/wallet/onboard" "" "3. Onboarding Provider1 (P1)"
invoke_curl_robust "POST" "$Provider2Url/api/v1/wallet/onboard" "" "4. Onboarding Provider2 (P2)"

# ----------------------------
# 2.4 Obtención de DIDs
# ----------------------------
echo "" >&2
echo "--- 4. Getting DIDs of participants ---" >&2

# Extraemos la propiedad .id del JSON de respuesta
AuthorityDid=$(invoke_curl_robust "GET" "$AuthorityUrl/api/v1/wallet/did.json" "" "4.1 Get A Did" | jq -r '.id')
ConsumerDid=$(invoke_curl_robust "GET" "$ConsumerUrl/api/v1/wallet/did.json" "" "4.2 Get C Did" | jq -r '.id')
Provider1Did=$(invoke_curl_robust "GET" "$Provider1Url/api/v1/wallet/did.json" "" "4.3 Get P1 Did" | jq -r '.id')
Provider2Did=$(invoke_curl_robust "GET" "$Provider2Url/api/v1/wallet/did.json" "" "4.4 Get P2 Did" | jq -r '.id')

echo "Authority DID: $AuthorityDid" >&2
echo "Consumer DID:  $ConsumerDid" >&2
echo "Provider1 DID:  $Provider1Did" >&2
echo "Provider2 DID:  $Provider2Did" >&2
echo "-----------------------------------------------" >&2


# ----------------------------
# 2.5 Consumer solicita credencial (Beg for Credential)
# ----------------------------
# NOTA CRÍTICA: En PowerShell el slug es "rainbow_authority", no "authority".
# Mapeo de variables PowerShell -> jq:
# $C_BEG_BODY = @{ url=...FromDocker, id=$AUTH_DID, slug="rainbow_authority", ... }

C_BEG_BODY=$(jq -n \
    --arg url "$AuthorityUrlFromDocker/api/v1/gate/access" \
    --arg id "$AuthorityDid" \
    --arg slug "rainbow_authority" \
    --arg vc_type "DataspaceParticipantCredential" \
    '{"url": $url, "id": $id, "slug": $slug, "vc_type": $vc_type}')

invoke_curl_robust "POST" "$ConsumerUrl/api/v1/vc-request/beg/cross-user" "$C_BEG_BODY" "5. Consumer Request Completed (Beg)"


# ----------------------------
# 2.6 Authority obtiene todas las peticiones y extrae el ID
# ----------------------------
# PowerShell: $ALL_REQUESTS[-1].id

ALL_REQUESTS_JSON=$(invoke_curl_robust "GET" "$AuthorityUrl/api/v1/vc-request/all" "" "6. A Retrieves all Requests")

PetitionId=$(echo "$ALL_REQUESTS_JSON" | jq -r '.[-1].id')

if [[ -z "$PetitionId" || "$PetitionId" == "null" ]]; then
    echo "ERROR: Could not get PetitionId. Exiting." >&2
    exit 1
fi
echo "Petition ID: $PetitionId" >&2


# ----------------------------
# 2.7 Authority aprueba la petición
# ----------------------------
# PowerShell: $APPROVE_BODY = @{ approve = $true }

APPROVE_BODY='{"approve": true}'
invoke_curl_robust "POST" "$AuthorityUrl/api/v1/vc-request/$PetitionId" "$APPROVE_BODY" "7. Request Approved (Authority)"


# ----------------------------
# 2.8 Consumer obtiene OIDC4VCI URI
# ----------------------------
# PowerShell: $OIDC4VCI_URI = $ALL_AUTHORITY[-1].vc_uri

ALL_AUTHORITY_JSON=$(invoke_curl_robust "GET" "$ConsumerUrl/api/v1/vc-request/all" "" "8. C Retrieves Authorities (Get OIDC4VCI URI)")

OIDC4VCI_URI=$(echo "$ALL_AUTHORITY_JSON" | jq -r '.[-1].vc_uri')

if [[ -z "$OIDC4VCI_URI" || "$OIDC4VCI_URI" == "null" ]]; then
    echo "ERROR: Could not get OIDC4VCI_URI. Exiting." >&2
    exit 1
fi
echo "OIDC4VCI_URI: $OIDC4VCI_URI" >&2


# ----------------------------
# 2.9 Consumer procesa OIDC4VCI
# ----------------------------
# PowerShell: Invoke-CurlJson ... -Body @{ uri = $OIDC4VCI_URI }

OIDC4VCI_PROCESS_BODY=$(jq -n --arg uri "$OIDC4VCI_URI" '{"uri": $uri}')
invoke_curl_robust "POST" "$ConsumerUrl/api/v1/wallet/oidc4vci" "$OIDC4VCI_PROCESS_BODY" "9. OIDC4VCI Processed"


# ----------------------------
# 2.10 Consumer solicita acceso al Provider1 (OIDC4VP Grant)
# ----------------------------
# NOTA CRÍTICA: En PowerShell el slug es "rainbow_provider", no "provider".
# Mapeo de variables PowerShell -> jq:
# $OIDC4VP_BODY = @{ url=...FromDocker, id=$PROVIDER_DID, slug="rainbow_provider", actions="talk" }

OIDC4VP_BODY_P1=$(jq -n \
    --arg url "$Provider1UrlFromDocker/api/v1/gate/access" \
    --arg id "$Provider1Did" \
    --arg slug "rainbow_provider" \
    --arg actions "talk" \
    '{"url": $url, "id": $id, "slug": $slug, "actions": $actions}')

# La respuesta es el URI en texto plano
OIDC4VP_URI_RAW_P1=$(invoke_curl_robust "POST" "$ConsumerUrl/api/v1/onboard/provider" "$OIDC4VP_BODY_P1" "10. Consumer requests grant from Provider (Get OIDC4VP URI)")

# Limpieza de espacios en blanco
OIDC4VP_URI_P1=$(echo "$OIDC4VP_URI_RAW_P1" | tr -d '[:space:]')

if [[ -z "$OIDC4VP_URI_P1" ]]; then
    echo "ERROR: Could not get OIDC4VP_URI. Exiting." >&2
    exit 1
fi
echo "OIDC4VP_URI: $OIDC4VP_URI_P1" >&2

# ----------------------------
# 2.10 Consumer solicita acceso al Provider2 (OIDC4VP Grant)
# ----------------------------
OIDC4VP_BODY_P2=$(jq -n \
    --arg url "$Provider2UrlFromDocker/api/v1/gate/access" \
    --arg id "$Provider2Did" \
    --arg slug "rainbow_provider" \
    --arg actions "talk" \
    '{"url": $url, "id": $id, "slug": $slug, "actions": $actions}')

# La respuesta es el URI en texto plano
OIDC4VP_URI_RAW_P2=$(invoke_curl_robust "POST" "$ConsumerUrl/api/v1/onboard/provider" "$OIDC4VP_BODY_P2" "10. Consumer requests grant from Provider (Get OIDC4VP URI)")

# Limpieza de espacios en blanco
OIDC4VP_URI_P2=$(echo "$OIDC4VP_URI_RAW_P2" | tr -d '[:space:]')

if [[ -z "$OIDC4VP_URI_P2" ]]; then
    echo "ERROR: Could not get OIDC4VP_URI. Exiting." >&2
    exit 1
fi
echo "OIDC4VP_URI: $OIDC4VP_URI_P2" >&2



# ----------------------------
# 2.11 Consumer procesa OIDC4VP
# ----------------------------
# PowerShell: Invoke-CurlJson ... -Body @{ uri = $OIDC4VP_URI }

echo "Consumer processes OIDC4VP..." >&2
OIDC4VP_PROCESS_BODY=$(jq -n --arg uri "$OIDC4VP_URI" '{"uri": $uri}')
invoke_curl_robust "POST" "$ConsumerUrl/api/v1/wallet/oidc4vp" "$OIDC4VP_PROCESS_BODY" "11. OIDC4VP Processed"

echo "" >&2
echo "================================================================" >&2
# Uso de códigos de escape ANSI para color verde (32m) similar al Write-Host -ForegroundColor Green
echo -e "\033[0;32mOnboarding script finished successfully!\033[0m" >&2
echo "================================================================" >&2