param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$environmentPath = Join-Path $root "environments/$Environment"

if (-not (Test-Path $environmentPath)) {
    throw "Directory ambiente non trovata: $environmentPath"
}

az account set --subscription $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    throw "Impossibile selezionare la subscription Azure."
}

$env:ARM_SUBSCRIPTION_ID = $SubscriptionId

Push-Location $environmentPath

try {
    terraform init -reconfigure `
        -backend-config="resource_group_name=rg-tfstate" `
        -backend-config="storage_account_name=$StorageAccountName" `
        -backend-config="container_name=tfstate" `
        -backend-config="key=app/$Environment.terraform.tfstate" `
        -backend-config="use_azuread_auth=true"

    if ($LASTEXITCODE -ne 0) {
        throw "Inizializzazione Terraform fallita."
    }
}
finally {
    Pop-Location
}