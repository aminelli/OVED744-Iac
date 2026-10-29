$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$environments = @("dev", "test", "prod")

foreach ($environment in $environments) {
    $path = Join-Path $root "environments/$environment"

    Write-Host "Validazione: $environment"

    Push-Location $path

    try {
        terraform fmt -check -recursive

        if ($LASTEXITCODE -ne 0) {
            throw "Formattazione non valida: $environment"
        }

        terraform init -backend=false

        if ($LASTEXITCODE -ne 0) {
            throw "Inizializzazione locale fallita: $environment"
        }

        terraform validate

        if ($LASTEXITCODE -ne 0) {
            throw "Validazione fallita: $environment"
        }
    }
    finally {
        Pop-Location
    }
}