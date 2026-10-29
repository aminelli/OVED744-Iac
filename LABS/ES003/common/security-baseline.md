# Baseline di sicurezza

- Autenticazione SSH tramite chiave pubblica.
- Nessuna password amministrativa nel codice.
- Nessuna credenziale nei file terraform.tfvars.
- Accesso SSH limitato a CIDR autorizzati.
- State conservato in Azure Blob privato.
- Autenticazione del backend tramite Microsoft Entra ID.
- Approvazione obbligatoria prima del deployment PROD.
- Protezione dei file di piano e dello state.
- Verifica della disponibilità degli SKU Azure.