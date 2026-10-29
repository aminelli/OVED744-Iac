# Procedura completa di esecuzione

L'ordine consigliato è il seguente.

1. Preparare gli strumenti

   Installare Terraform e Azure CLI, verificare la versione del provider e predisporre la chiave SSH.
2. Autenticarsi su Azure

   Eseguire `az login`, selezionare la subscription e configurare `ARM_SUBSCRIPTION_ID`.
3. Creare il backend

   Eseguire il bootstrap da `bootstrap/tfstate`, dopo aver predisposto l'identità e lo state iniziale.
4. Validare il repository

   Eseguire `scripts/validate-all.ps1` per controllare i root module.
5. Inizializzare DEV

   Eseguire lo script `init-environment.ps1` con `-Environment dev`.
6. Pianificare e applicare DEV

   Da `environments/dev`, eseguire `terraform plan -out=dev.tfplan`, revisionare il piano e applicarlo.
7. Promuovere a TEST e PROD

   Inizializzare separatamente i rispettivi backend, esaminare i piani e rispettare le approvazioni previste.

Esempio per inizializzare DEV da PowerShell, dalla root del repository:

```
az login

.\scripts\init-environment.ps1 `
    -Environment dev `
    -StorageAccountName "<STORAGE_ACCOUNT>" `
    -SubscriptionId "<SUBSCRIPTION_ID>"
```

Poi:

```
Set-Location environments/dev

terraform fmt -check
terraform validate
terraform plan -out=dev.tfplan
```

Dopo la revisione del piano:

```
terraform apply dev.tfplan

terraform output
```

Per TEST e PROD ripeti la procedura con i rispettivi ambienti. Non riutilizzare un piano salvato dopo aver cambiato ambiente o configurazione.
