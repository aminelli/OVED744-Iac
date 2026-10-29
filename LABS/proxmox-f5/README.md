# Deploy F5 BIG-IP VE (LTM) su Proxmox con Terraform

Infrastruttura come codice per:

1. creare su **Proxmox VE 9.2.x** una VM **F5 BIG-IP Virtual Edition (LTM)** a partire dall'immagine qcow2 ufficiale F5 (17.1.x);
2. configurare su BIG-IP un **Virtual Server HTTPS (443)** con **pool di 2 nodi**, terminazione TLS (client SSL profile) sul BIG-IP.

Provider usati: [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox) (~> 0.118), [`F5Networks/bigip`](https://registry.terraform.io/providers/F5Networks/bigip) (~> 1.29), `hashicorp/tls` (~> 4.0). Sintassi validata con `terraform validate` (Terraform 1.11.4).

## 1. Struttura del repository

```text
proxmox-f5/
├── README.md
├── .gitignore
├── 01-proxmox-vm/            # Stack 1: VM su Proxmox
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── 02-bigip-config/          # Stack 2: configurazione LTM su BIG-IP
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

### Perché due stack separati?

Il provider `bigip` ha bisogno dell'indirizzo di management e di credenziali valide **già in fase di plan**, ma BIG-IP è raggiungibile solo dopo: boot della VM → cambio password → licenza → provisioning LTM. Questi passaggi non sono eseguibili in modo affidabile da Terraform (nessun guest agent, nessun cloud-init supportato in modo documentato su KVM). Con due stack indipendenti si evitano provider con valori sconosciuti e si gestisce il ciclo di vita in modo pulito. Tra i due stack c'è quindi una **fase di bootstrap manuale** (sezione 5).

## 2. Architettura e scelte di design

| Elemento | Valore di default | Note |
|---|---|---|
| Rete Proxmox | 1 bridge (`vmbr0`) | come da requisito: un solo bridge/NIC fisica |
| NIC VM | **2 NIC virtio** sullo stesso bridge | NIC0 = management (`mgmt`), NIC1 = data plane (interfaccia BIG-IP `1.1`) |
| IP management | `192.168.10.50` (DHCP reservation) | MAC fisso `BC:24:11:F5:00:01` |
| Self IP (`1.1`) | `192.168.10.51/24` | VLAN `/Common/vlan_data`, untagged |
| VIP | `192.168.10.60:443` | virtual server HTTPS con client SSL |
| Pool | `web-01` `192.168.10.71:80`, `web-02` `192.168.10.72:80` | round-robin, monitor TCP |
| Certificato | self-signed RSA 2048, CN `app.lab.local` | generato da Terraform (`tls`) |

> **Importante – deviazione dal requisito "un NIC":** su BIG-IP VE la prima NIC è sempre l'interfaccia di **management** (non partecipa al data plane TMM). Per servire traffico LTM serve almeno una seconda NIC (`1.1`). Si usa quindi **un solo bridge Proxmox** ma **due NIC virtuali** sullo stesso. Esiste un modello "single NIC" documentato da F5 per i cloud pubblici (AWS/Azure/GCP), ma non l'ho verificato su KVM/Proxmox, quindi non lo adotto. Per usarlo, riduci `network_interfaces` a un elemento (non testato).
>
> Mgmt e data sulla stessa subnet funziona in lab, ma in produzione è consigliato separarle (VLAN diverse, `network_vlan_id` o secondo bridge).

I valori di rete (IP, VIP, nodi) sono **segnaposto**: sostituiscili nei file `terraform.tfvars`.

## 3. Prerequisiti

### 3.1 Workstation (Windows o Linux/WSL)

- Terraform >= 1.6 (`terraform version`).
- Client OpenSSH e **ssh-agent** attivo con la chiave autorizzata per l'utente SSH sul nodo Proxmox (richiesto dal provider `bpg/proxmox`, vedi 3.3).
- Accesso di rete a: API Proxmox (`:8006`), SSH nodo Proxmox (`:22`), management BIG-IP (`:443`).

Installazione Terraform:

```powershell
# Windows
winget install Hashicorp.Terraform
```

```bash
# Linux (Debian/Ubuntu, repo HashiCorp già configurato)
sudo apt-get update && sudo apt-get install terraform
```

ssh-agent su Windows (PowerShell come amministratore, una tantum):

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

Su Linux/WSL: `eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519`.

### 3.2 Immagine BIG-IP

1. Scarica da F5 (downloads.f5.com, account con entitlement) l'immagine **BIG-IP VE per KVM** (file `.qcow2.zip`, versione 17.1.x, bundle LTM/"ALL"). Verifica nella pagina di download F5 il nome esatto del file per la tua versione.
2. **Decomprimi** il file: serve il `.qcow2`.
3. Il nome file deve terminare con `.qcow2` (richiesto da Proxmox per l'import).
4. Copialo nella cartella `import` di uno storage di tipo *directory* del nodo Proxmox con contenuto **Import** abilitato (di default `local` → `/var/lib/vz/import/`):

```bash
# dal nodo Proxmox: abilita il content type "import" su "local" se non presente
pvesm set local --content iso,vztmpl,backup,import   # includi i content type già in uso!
mkdir -p /var/lib/vz/import
```

```powershell
# dalla workstation (Windows o Linux): copia il file
scp .\BIGIP-17.1.2.ALL.qcow2 root@<IP_PROXMOX>:/var/lib/vz/import/
```

> Controlla prima i content type esistenti con `pvesm status` / GUI (*Datacenter → Storage → local → Content*) e **aggiungi** `import` senza rimuovere gli altri. Il nome `BIGIP-17.1.2.ALL.qcow2` è solo un esempio: imposta `image_file_name` al nome reale.

### 3.3 Utente/API token Proxmox

Il provider `bpg/proxmox` usa l'API per la gestione della VM e **SSH sul nodo** per l'import del disco. Creazione di un token (sul nodo, come root):

```bash
pveum user add terraform@pve
pveum role add TerraformF5 -privs "VM.Allocate VM.Audit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.PowerMgmt VM.Monitor Datastore.AllocateSpace Datastore.Audit SDN.Use Sys.Audit"
pveum aclmod / -user terraform@pve -role TerraformF5
pveum user token add terraform@pve f5 --privsep 0
```

Il comando stampa il valore `full-tokenid` (`terraform@pve!f5`) e il `value` (segreto, mostrato **una sola volta**). Il token da passare a Terraform è `terraform@pve!f5=<secret>`.

> L'elenco dei privilegi è un punto di partenza; se `terraform apply` segnala `permission check failed`, aggiungi il privilegio indicato. In lab si può usare il ruolo `Administrator`. Verifica sempre contro la documentazione del provider.
>
> L'utente SSH (default `root`) deve poter scrivere sullo storage di destinazione; con utenti non-root consulta la sezione SSH della documentazione del provider (richiede `sudo` senza password).

### 3.4 DHCP

Crea sul tuo DHCP una **reservation**: MAC `BC:24:11:F5:00:01` → IP di management desiderato (es. `192.168.10.50`). BIG-IP VE al primo avvio usa DHCP sull'interfaccia di management. Alternativa senza DHCP: configurazione da console (sezione 5.2).

## 4. Stack 1 – Creazione VM Proxmox

```bash
cd 01-proxmox-vm
cp terraform.tfvars.example terraform.tfvars     # Windows: Copy-Item terraform.tfvars.example terraform.tfvars
```

Modifica `terraform.tfvars` (`proxmox_endpoint`, `proxmox_api_token`, `proxmox_node_name`, `image_file_name`, datastore, bridge). Il token si può passare anche da ambiente:

```powershell
$env:TF_VAR_proxmox_api_token = "terraform@pve!f5=<secret>"   # PowerShell
```
```bash
export TF_VAR_proxmox_api_token='terraform@pve!f5=<secret>'   # bash
```

Esecuzione:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

Risorsa creata: `proxmox_virtual_environment_vm.bigip` con:
- 4 vCPU (`cpu type = host`), 8 GiB RAM (variabili `vm_cpu_cores`, `vm_memory_mb`; verifica il dimensionamento richiesto dalla tua licenza/moduli sulla documentazione F5 VE);
- disco importato da `local:import/<file>.qcow2` su `scsi0` (controller `virtio-scsi-pci`), dimensione ereditata dall'immagine;
- BIOS SeaBIOS, NIC virtio con MAC fissi, `serial_device`, `on_boot = true`, guest agent disabilitato.

> **Da verificare sul tuo ambiente:** controller/bus del disco (`scsi_hardware`, `disk_interface`). Se la VM non effettua il boot (console Proxmox ferma su "No bootable device" o kernel panic per disco non trovato), prova a cambiare tali valori in base alle indicazioni F5 per l'immagine KVM scelta.

## 5. Bootstrap manuale di BIG-IP (obbligatorio)

### 5.1 Attesa boot

Il primo avvio richiede alcuni minuti. Segui da *Proxmox → VM → Console*. Quando compare il prompt `login:` il sistema è avviato.

### 5.2 Primo accesso, password e IP di management

Credenziali iniziali (documentate da F5 per VE): `root` / `default`, `admin` / `admin` (al primo login è richiesto il cambio password).

Da console Proxmox (o SSH se il DHCP ha assegnato l'IP):

```bash
# Login come root, cambia la password quando richiesto
tmsh modify auth user admin password '<NUOVA_PASSWORD_ADMIN>'
tmsh modify auth user admin shell bash       # opzionale
tmsh save sys config
```

Se **non** usi DHCP, imposta l'IP di management statico:

```bash
tmsh modify sys global-settings mgmt-dhcp disabled
tmsh create sys management-ip 192.168.10.50/24
tmsh create sys management-route default gateway 192.168.10.1
tmsh save sys config
```

Verifica: `tmsh list sys management-ip` e `ping` dalla workstation.

### 5.3 Licenza (trial/eval)

Il mgmt BIG-IP deve raggiungere Internet (activation server F5). Da shell BIG-IP:

```bash
tmsh install sys license registration-key <TRIAL-KEY>
tmsh show sys license
```

Senza accesso Internet usa l'attivazione manuale (dossier) dalla GUI: *System → License → Manual*.

### 5.4 Provisioning del modulo LTM

```bash
tmsh modify sys provision ltm level nominal
tmsh save sys config
tmsh show sys provision
tmsh show sys mcp-state field-fmt     # attendere "running"
```

Attendi qualche minuto finché `tmsh show sys mcp-state` indica `running` e la GUI `https://<IP_MGMT>/` risponde. Verifica l'interfaccia dati:

```bash
tmsh show net interface            # deve comparire 1.1 (stato up)
```

### 5.5 Test API

```bash
curl -k -u admin:'<PASSWORD>' https://192.168.10.50/mgmt/tm/sys/version
```

Windows PowerShell: usa `curl.exe` (non l'alias `curl`).

## 6. Stack 2 – Configurazione LTM

```bash
cd ../02-bigip-config
cp terraform.tfvars.example terraform.tfvars
```

Imposta in `terraform.tfvars`: `bigip_address`, `selfip_cidr`, `vip_address`, `pool_members`, `pool_member_port`. La password **non** va nel file:

```powershell
$env:TF_VAR_bigip_password = "<PASSWORD_ADMIN>"       # PowerShell
```
```bash
export TF_VAR_bigip_password='<PASSWORD_ADMIN>'       # bash
```

```bash
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

### Oggetti creati (`02-bigip-config/main.tf`)

| Risorsa Terraform | Oggetto BIG-IP |
|---|---|
| `bigip_net_vlan.data` | VLAN `/Common/vlan_data` su interfaccia `1.1` (untagged) |
| `bigip_net_selfip.data` | Self IP `192.168.10.51/24`, port lockdown `none` |
| `tls_private_key` / `tls_self_signed_cert` | Chiave + certificato self-signed (nello state Terraform!) |
| `bigip_ssl_key.vip`, `bigip_ssl_certificate.vip` | `app-web.key`, `app-web.crt` in `/Common` |
| `bigip_ltm_profile_client_ssl.vip` | Client SSL profile (figlio di `/Common/clientssl`) con cert/key |
| `bigip_ltm_monitor.health` | Monitor (`/Common/tcp` default; `/Common/http` supportato) |
| `bigip_ltm_node.member["web-01"/"web-02"]` | 2 nodi |
| `bigip_ltm_pool.app` + `bigip_ltm_pool_attachment.member` | Pool con 2 membri sulla porta `pool_member_port` |
| `bigip_ltm_virtual_server.https` | VS `192.168.10.60:443`, profili `tcp`+`http`+client SSL, SNAT automap |

Design: TLS terminato sul BIG-IP (SSL offload); backend in HTTP (`pool_member_port = 80`). Per re-encrypt verso i nodi bisognerebbe aggiungere un server SSL profile (`server_profiles`) e porta 443 sui nodi: non incluso.

Per usare un monitor HTTP: `monitor_parent = "/Common/http"` (e, se serve, `monitor_send` / `monitor_receive`).

**Requisiti sui nodi:** devono essere raggiungibili dalla self IP (stessa subnet, o rotta configurata) e rispondere sulla porta configurata. Con SNAT automap il traffico verso i nodi esce con la self IP, quindi non serve gateway di default sui nodi verso il BIG-IP.

### Certificato proprio

Per usare un certificato aziendale al posto del self-signed, rimuovi `tls_private_key.vip` / `tls_self_signed_cert.vip` e sostituisci i `content` di `bigip_ssl_key.vip` e `bigip_ssl_certificate.vip` con `file("percorso/key.pem")` e `file("percorso/cert.pem")`.

> **Sicurezza:** chiave privata e password finiscono nello **state Terraform** in chiaro. Proteggi `terraform.tfstate` (backend remoto cifrato, permessi ristretti). Il provider `bigip_ssl_key` espone anche `content_wo` (write-only, non salvato in state) come alternativa.

## 7. Verifica

```bash
terraform output vip_url
curl -vk https://192.168.10.60/
```

Su BIG-IP:

```bash
tmsh show ltm virtual app-web-vs-https
tmsh show ltm pool app-web-pool members
tmsh list ltm virtual app-web-vs-https
```

I membri devono risultare `available` (monitor ok). Nella GUI: *Local Traffic → Virtual Servers / Pools*. Con round-robin le richieste successive devono alternare i due nodi.

## 8. Modifiche successive

- Cambiare VIP, nodi, porta, metodo LB: modifica `terraform.tfvars` dello stack 2, poi `plan` / `apply`.
- Aggiungere un nodo: aggiungi una voce a `pool_members` (la chiave diventa il nome del nodo).
- Cambiare CPU/RAM: stack 1, `plan` / `apply` (può richiedere riavvio della VM).

## 9. Distruzione dell'ambiente

Ordine **inverso** alla creazione.

```bash
# 1) Configurazione LTM
cd 02-bigip-config
terraform destroy

# 2) VM Proxmox
cd ../01-proxmox-vm
terraform destroy
```

Note:
- Lo stack 2 va distrutto **prima** che la VM sparisca; se la VM è già stata eliminata, `destroy` fallirà perché BIG-IP non è raggiungibile: in tal caso usa `terraform state rm` per le risorse o elimina la cartella dello state.
- `destroy` dello stack 1 elimina VM e disco; il file qcow2 in `import/` **non** viene toccato.
- Per liberare la licenza trial (opzionale, prima del destroy) revocala dalla GUI/`tmsh revoke sys license` secondo le policy F5.
- Rimuovere anche la reservation DHCP e i file `terraform.tfstate*` locali (contengono segreti).

## 10. Troubleshooting

| Sintomo | Causa probabile / azione |
|---|---|
| `terraform apply` stack 1: errore su import disco | File non in `<datastore>/import/`, estensione non `.qcow2`, content type `import` non abilitato, SSH non funzionante (`ssh-add -l`) |
| `permission check failed` | Privilegi mancanti sul token/ruolo (sezione 3.3) |
| VM non fa boot | Verificare `scsi_hardware`/`disk_interface`, console Proxmox, integrità dell'immagine |
| Nessun IP di management | DHCP reservation errata o assente: configurazione statica da console (5.2) |
| Stack 2: `401` / errore autenticazione | Password admin non ancora cambiata o variabile `TF_VAR_bigip_password` non impostata |
| Stack 2: errori su create object subito dopo il boot | BIG-IP non ancora `running`/licenziato/provisioned (5.3–5.4); attendi e riesegui |
| Stack 2: VLAN con interfaccia `1.1` inesistente | La VM ha una sola NIC o `1.1` non è stata rilevata (`tmsh show net interface`) |
| Pool member `offline` | Nodo non raggiungibile da self IP, porta/monitor errati, firewall sul nodo |
| `curl` al VIP non risponde | Self IP/VLAN errati, VIP fuori subnet senza ARP raggiungibile, Proxmox firewall o MAC filtering sul bridge |

Debug Terraform: `TF_LOG=DEBUG terraform apply` (Linux) / `$env:TF_LOG="DEBUG"` (PowerShell).

## 11. Limiti e punti da verificare

- Non è stato eseguito un deploy reale: gli script sono validati sintatticamente (`terraform validate`) e allineati alla documentazione ufficiale dei provider, ma i valori specifici dell'ambiente (disk bus, privilegi Proxmox, comportamento primo boot) vanno confermati.
- Il bootstrap (password/licenza/provisioning) è manuale per scelta; è automatizzabile con script SSH/`tmsh` o con F5 Declarative Onboarding (DO), non incluso.
- Nessun HA, nessuna rotta di default sul BIG-IP, nessun backend state remoto: aggiungili per ambienti oltre il laboratorio.
