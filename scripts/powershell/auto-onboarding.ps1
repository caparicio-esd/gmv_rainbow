# auto-onboarding.ps1
param(
    [string]$AuthorityUrl = "http://127.0.0.1:1500",
    [string]$ConsumerUrl  = "http://127.0.0.1:1100",
    [string]$Provider1Url  = "http://127.0.0.1:1200",
    [string]$Provider2Url  = "http://127.0.0.1:1800",
    [string]$AuthorityUrlFromDocker = "http://host.docker.internal:1500",
    [string]$ConsumerUrlFromDocker  = "http://host.docker.internal:1100",
    [string]$Provider1UrlFromDocker  = "http://host.docker.internal:1200",
    [string]$Provider2UrlFromDocker  = "http://host.docker.internal:1800"
)

function Invoke-CurlJson {
    param(
        [string]$Method = "GET",
        [string]$Url,
        [object]$Body = $null,
        [bool]$ParseJson = $true  # parsea a JSON solo si se espera JSON
    )

    try {
        $Params = @{
            Method      = $Method
            Uri         = $Url
            ContentType = "application/json"
            ErrorAction = 'Stop'
        }

        if ($Body) { $Params.Body = $Body | ConvertTo-Json -Compress }

        $Response = Invoke-WebRequest @Params

        if ($Response.StatusCode -ge 200 -and $Response.StatusCode -lt 300) {
            Write-Host "SUCCESS: $Method $Url returned $($Response.StatusCode)" -ForegroundColor Green
        } else {
            Write-Host "ERROR: $Method $Url returned $($Response.StatusCode)" -ForegroundColor Red
            exit 1
        }

        if ($ParseJson -and $Response.Content) {
            return $Response.Content | ConvertFrom-Json
        } else {
            return $Response.Content
        }

    } catch {
        Write-Host "ERROR: Request to $Url failed" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "The script wont continue executing" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

Write-Host "Starting auto-onboarding script..."

# ----------------------------
# Onboarding Authority / Consumer / Provider1 (no se parsea JSON) / Provider2
# ----------------------------
Invoke-CurlJson -Method "POST" -Url "$AuthorityUrl/api/v1/wallet/onboard" -ParseJson:$false
Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/wallet/onboard" -ParseJson:$false
Invoke-CurlJson -Method "POST" -Url "$Provider1Url/api/v1/wallet/onboard" -ParseJson:$false
Invoke-CurlJson -Method "POST" -Url "$Provider2Url/api/v1/wallet/onboard" -ParseJson:$false

# ----------------------------
# Getting DIDs
# ----------------------------
$AUTH_DID     = (Invoke-CurlJson -Url "$AuthorityUrl/api/v1/wallet/did.json").id
Write-Host "Authority DID: $AUTH_DID"
$CONSUMER_DID = (Invoke-CurlJson -Url "$ConsumerUrl/api/v1/wallet/did.json").id
Write-Host "Consumer DID: $CONSUMER_DID"
$PROVIDER1_DID = (Invoke-CurlJson -Url "$Provider1Url/api/v1/wallet/did.json").id
Write-Host "Provider1 DID: $PROVIDER1_DID"
$PROVIDER2_DID = (Invoke-CurlJson -Url "$Provider2Url/api/v1/wallet/did.json").id
Write-Host "Provider2 DID: $PROVIDER2_DID"


# ----------------------------
# Consumer begins request for credential
# ----------------------------
$C_BEG_BODY = @{
    url = "$AuthorityUrlFromDocker/api/v1/gate/access"
    id  = $AUTH_DID
    slug = "rainbow_authority"
    vc_type = "DataspaceParticipantCredential"
}
$C_BEG_RESPONSE = Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/vc-request/beg/cross-user" -Body $C_BEG_BODY -ParseJson:$false
Write-Host "Consumer request completed."

# ----------------------------
# Get all requests from Authority
# ----------------------------
$ALL_REQUESTS = Invoke-CurlJson -Url "$AuthorityUrl/api/v1/vc-request/all"
$PETITION_ID = $ALL_REQUESTS[-1].id
Write-Host "Petition ID: $PETITION_ID"

# ----------------------------
# Authority approves request
# ----------------------------
$APPROVE_BODY = @{ approve = $true }
Invoke-CurlJson -Method "POST" -Url "$AuthorityUrl/api/v1/vc-request/$PETITION_ID" -Body $APPROVE_BODY -ParseJson:$false
Write-Host "Request approved."

# ----------------------------
# Get all authority requests for Consumer
# ----------------------------
$ALL_AUTHORITY = Invoke-CurlJson -Url "$ConsumerUrl/api/v1/vc-request/all"
$OIDC4VCI_URI = $ALL_AUTHORITY[-1].vc_uri
Write-Host "OIDC4VCI_URI: $OIDC4VCI_URI"

# ----------------------------
# Consumer processes OIDC4VCI
# ----------------------------
Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/wallet/oidc4vci" -Body @{ uri = $OIDC4VCI_URI } -ParseJson:$false
Write-Host "OIDC4VCI processed."

# ----------------------------
# AUTENTICACIÓN CON PROVIDER 1
# ----------------------------
Write-Host ""
Write-Host "=== AUTHENTICATING WITH PROVIDER1 ===" -ForegroundColor Cyan

$OIDC4VP_BODY_P1 = @{
    url = "$Provider1UrlFromDocker/api/v1/gate/access"
    id  = $PROVIDER1_DID
    slug = "rainbow_provider"
    actions = "talk"
}
$OIDC4VP_URI_P1 = Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/onboard/provider" -Body $OIDC4VP_BODY_P1 -ParseJson:$false
Write-Host "OIDC4VP_URI Provider1: $OIDC4VP_URI_P1"

Write-Host "Consumer processes OIDC4VP for Provider1..."
Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/wallet/oidc4vp" -Body @{ uri = $OIDC4VP_URI_P1 } -ParseJson:$false
Write-Host "OIDC4VP for Provider1 processed." -ForegroundColor Green

# ----------------------------
# AUTENTICACIÓN CON PROVIDER 2
# ----------------------------
Write-Host ""
Write-Host "=== AUTHENTICATING WITH PROVIDER2 ===" -ForegroundColor Cyan

$OIDC4VP_BODY_P2 = @{
    url = "$Provider2UrlFromDocker/api/v1/gate/access"
    id  = $PROVIDER2_DID
    slug = "rainbow_provider"
    actions = "talk"
}
$OIDC4VP_URI_P2 = Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/onboard/provider" -Body $OIDC4VP_BODY_P2 -ParseJson:$false
Write-Host "OIDC4VP_URI Provider2: $OIDC4VP_URI_P2"

Write-Host "Consumer processes OIDC4VP for Provider2..."
Invoke-CurlJson -Method "POST" -Url "$ConsumerUrl/api/v1/wallet/oidc4vp" -Body @{ uri = $OIDC4VP_URI_P2 } -ParseJson:$false
Write-Host "OIDC4VP for Provider2 processed." -ForegroundColor Green

Write-Host ""
Write-Host "Onboarding script finished successfully!" -ForegroundColor Green
Write-Host ""