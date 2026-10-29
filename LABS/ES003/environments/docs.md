

| Proprietà      | DEV            | TEST              | PROD              |
| -------------- | -------------- | ----------------- | ----------------- |
| Resource Group | `rg-app-dev`   | `rg-app-test`     | `rg-app-prod`     |
| VM             | `vm-app-dev`   | `vm-app-test`     | `vm-app-prod`     |
| VNet           | `10.20.0.0/16` | `10.30.0.0/16`    | `10.40.0.0/16`    |
| SKU            | `Standard_B2s` | `Standard_D2s_v5` | `Standard_D4s_v5` |
| Disco OS       | 64 GB          | 64 GB             | 128 GB            |
| Criticità      | Low            | Medium            | High              |


| Ambiente | Chiave                       |
| -------- | ---------------------------- |
| DEV      | `app/dev.terraform.tfstate`  |
| TEST     | `app/test.terraform.tfstate` |
| PROD     | `app/prod.terraform.tfstate` |

