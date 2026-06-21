# ha-gcp-azure-terraform

# HA Multi-Cloud Infrastructure on Azure + GCP using Terraform

> Production-ready reference architecture for deploying highly available infrastructure across Microsoft Azure and Google Cloud Platform using Terraform.

---

## Architecture

```mermaid
flowchart TB

GitHub["GitHub<br/>Source + Actions CI"]

TF["Terraform Orchestrator<br/>Providers: AzureRM + Google + Random"]

GitHub -->|"terraform apply"| TF

subgraph Azure["Azure — Primary Region"]
direction TB

AZ_RG["Resource Group"]
AZ_VNET["Virtual Network"]
AZ_SUB["Subnets"]
AZ_LB["Load Balancer"]
AZ_K8S["Kubernetes / Compute"]
AZ_MON["Monitoring"]

AZ_RG --> AZ_VNET
AZ_VNET --> AZ_SUB
AZ_SUB --> AZ_LB
AZ_LB --> AZ_K8S
AZ_K8S --> AZ_MON

end

subgraph GCP["GCP — Secondary Region"]
direction TB

GCP_PROJ["Project"]
GCP_VPC["VPC Network"]
GCP_SUB["Subnets"]
GCP_LB["Load Balancer"]
GCP_K8S["Kubernetes / Compute"]
GCP_MON["Monitoring"]

GCP_PROJ --> GCP_VPC
GCP_VPC --> GCP_SUB
GCP_SUB --> GCP_LB
GCP_LB --> GCP_K8S
GCP_K8S --> GCP_MON

end

TF --> Azure
TF --> GCP

AZ_K8S <-->|"Failover"| GCP_K8S

Shared["Shared Services<br/>DNS / State / Secrets<br/>Observability / Alerts"]

Azure --> Shared
GCP --> Shared

classDef cicd fill:#24292f,color:#fff,stroke:#000
classDef tf fill:#623CE4,color:#fff,stroke:#000
classDef azure fill:#0078D4,color:#fff,stroke:#000
classDef gcp fill:#34A853,color:#fff,stroke:#000
classDef shared fill:#F9AB00,color:#000,stroke:#000

class GitHub cicd
class TF tf
class AZ_RG,AZ_VNET,AZ_SUB,AZ_LB,AZ_K8S,AZ_MON azure
class GCP_PROJ,GCP_VPC,GCP_SUB,GCP_LB,GCP_K8S,GCP_MON gcp
class Shared shared
```





## Overview

This repository provisions a multi-cloud, highly available infrastructure topology across Azure and GCP using Terraform.

### Objectives

- High availability across cloud providers
- Infrastructure as Code (IaC)
- Automated deployment pipelines
- Disaster recovery readiness
- Cost visibility
- Secure-by-default configuration

---

## Features

- Multi-cloud deployment (Azure + GCP)
- Terraform modular architecture
- GitHub Actions integration
- Failover-ready topology
- Monitoring and observability
- Secure secrets handling
- Environment isolation

---

## Repository Structure

```mermaid
flowchart TB

ROOT["ha-gcp-azure-terraform/"]

ROOT --> MODULES["modules/"]
ROOT --> ENVS["environments/"]
ROOT --> SCRIPTS["scripts/"]
ROOT --> GITHUB[".github/"]
ROOT --> MAIN["main.tf"]
ROOT --> VARS["variables.tf"]
ROOT --> OUTPUTS["outputs.tf"]
ROOT --> README["README.md"]

subgraph MODULE_TREE["modules/"]
direction TB
AZ["azure/"]
GCP["gcp/"]
NET["network/"]
MON["monitoring/"]

MODULES --> AZ
MODULES --> GCP
MODULES --> NET
MODULES --> MON
end

subgraph ENV_TREE["environments/"]
direction TB
DEV["dev/"]
STAGE["stage/"]
PROD["prod/"]

ENVS --> DEV
ENVS --> STAGE
ENVS --> PROD
end

subgraph GITHUB_TREE[".github/"]
direction TB
WF["workflows/"]

GITHUB --> WF
end

classDef root fill:#24292f,color:#fff,stroke:#000
classDef folder fill:#4CAF50,color:#fff,stroke:#000
classDef terraform fill:#623CE4,color:#fff,stroke:#000
classDef config fill:#F9AB00,color:#000,stroke:#000

class ROOT root

class MODULES,ENVS,SCRIPTS,GITHUB folder
class AZ,GCP,NET,MON,DEV,STAGE,PROD,WF folder

class MAIN,VARS,OUTPUTS terraform
class README config
```


---

## Prerequisites

- Terraform >= 1.8
- Azure subscription
- GCP project
- GitHub repository secrets
- Azure CLI
- Google Cloud SDK

---

## Quick Start

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform fmt -recursive
terraform validate
```

### Preview

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

### Destroy

```bash
terraform destroy
```

---

## Deployment Flow

```text
Commit
 ↓
GitHub Actions
 ↓
Terraform Validate
 ↓
Terraform Plan
 ↓
Approval
 ↓
Terraform Apply
 ↓
Azure + GCP Deployment
 ↓
Health Checks
 ↓
Monitoring + Alerts
```

---

## Variables

| Variable | Description |
|---|---|
| azure_region | Azure deployment region |
| gcp_region | GCP deployment region |
| environment | Environment name |
| instance_count | Compute replicas |

---

## Outputs

| Output | Description |
|---|---|
| cluster_endpoint | Service endpoint |
| public_ip | Public ingress |
| monitoring_url | Monitoring dashboard |

---

## Failover Strategy

- Active / Passive topology
- Health probes
- DNS redirection
- Terraform state recovery

---

## Security

- Remote state protection
- Secret isolation
- Least privilege access
- Environment separation

---

## Monitoring

Suggested stack:

- Prometheus
- Grafana
- Cloud-native monitoring
- Alerting

---

## Cost Estimation

Track:

- Compute
- Networking
- Storage
- Monitoring
- Egress

---

## Troubleshooting

Common commands:

```bash
terraform state list
terraform plan
terraform refresh
```

---

## Roadmap

- Kubernetes support
- Cross-region replication
- Autoscaling
- Cost optimization
- Policy as code

---

## License

MIT
## 🧪 Local Development & Cloudless Testing

This repository supports **local execution and infrastructure validation without provisioning resources in Azure or Google Cloud**.

The goal of this mode is to enable:

- Local Terraform validation
- Development without cloud costs
- CI/CD smoke testing
- Module testing
- Kubernetes integration testing
- Faster feedback loops
- Offline experimentation

Instead of deploying to cloud providers, local emulators and compatible services are used.

---

## Architecture Overview

```text
Developer Machine
│
├── Docker Compose
│
├── Terraform
│
├── Local Cloud Emulators
│   │
│   ├── Azure Layer
│   │     ├── Azurite (Storage)
│   │     └── Kind (AKS replacement)
│   │
│   └── GCP Layer
│         ├── Fake GCS
│         ├── Pub/Sub Emulator
│         └── Firestore Emulator
│
├── Kubernetes (Kind)
│
└── Local Terraform Backend
```

---

## Supported Services

| Cloud Provider | Cloud Service | Local Replacement |
|---|---|---|
| Azure | Storage Account | Azurite |
| Azure | AKS | Kind |
| GCP | Cloud Storage | Fake GCS |
| GCP | Pub/Sub | Pub/Sub Emulator |
| GCP | Firestore | Firestore Emulator |
| Any | Terraform Backend | Local Backend |

> This environment is intended for development and validation. It is not a full cloud emulator.

---

## Prerequisites

Install the following tools:

### Required

- Docker
- Docker Compose
- Terraform >= 1.8
- kubectl
- Kind

Verify:

```bash
docker --version
terraform --version
kubectl version --client
kind version
```

---

## Clone Repository

```bash
git clone https://github.com/mjpinot/ha-gcp-azure-terraform

cd ha-gcp-azure-terraform
```

---

## Create Local Environment

Create:

```text
local/docker-compose.local.yml
```

```yaml
services:

  azurite:
    image: mcr.microsoft.com/azure-storage/azurite
    restart: unless-stopped

    ports:
      - "10000:10000"

  fake-gcs:
    image: fsouza/fake-gcs-server

    command:
      - -scheme
      - http

    ports:
      - "4443:4443"

  pubsub:
    image: messagebird/gcloud-pubsub-emulator

    ports:
      - "8681:8681"

  firestore:
    image: mtlynch/firestore-emulator

    ports:
      - "8080:8080"
```

Start services:

```bash
docker compose \
-f local/docker-compose.local.yml \
up -d
```

Validate:

```bash
docker ps
```

---

## Create Local Kubernetes Cluster

Start a local Kubernetes cluster:

```bash
kind create cluster \
--name ha-local
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
NAME
ha-local-control-plane
```

---

## Configure Terraform Local Backend

Create:

```text
local/backend.local.tf
```

```hcl
terraform {

  backend "local" {
    path = "./terraform.tfstate"
  }

}
```

Initialize:

```bash
terraform init
```

---

## Configure Local Environment Variables

Create:

```text
local/.env.local
```

```bash
USE_LOCALSTACK=true

AZURE_STORAGE_ENDPOINT=http://localhost:10000

GCS_ENDPOINT=http://localhost:4443

PUBSUB_EMULATOR_HOST=localhost:8681

FIRESTORE_EMULATOR_HOST=localhost:8080
```

Load variables:

### Linux / macOS

```bash
export $(cat local/.env.local | xargs)
```

### Windows PowerShell

```powershell
Get-Content local/.env.local |
foreach {
  $name,$value=$_.split('=')
  set-item env:$name $value
}
```

---

## Validate Terraform

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Preview:

```bash
terraform plan
```

Expected:

```text
No cloud resources created
```

---

## Apply Locally

```bash
terraform apply \
-auto-approve
```

Verify:

```bash
kubectl get all
```

---

## Cleanup

Destroy infrastructure:

```bash
terraform destroy \
-auto-approve
```

Delete cluster:

```bash
kind delete cluster \
--name ha-local
```

Stop emulators:

```bash
docker compose \
-f local/docker-compose.local.yml \
down
```

---

## CI/CD Example

Create:

```text
.github/workflows/local-validation.yml
```

```yaml
name: Local Validation

on:

  pull_request:

jobs:

  terraform:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Start Local Services
        run: |
          docker compose \
          -f local/docker-compose.local.yml \
          up -d

      - name: Init
        run: terraform init

      - name: Validate
        run: terraform validate

      - name: Plan
        run: terraform plan
```

---

## Recommended Repository Structure

```text
ha-gcp-azure-terraform/

├── local/
│   ├── docker-compose.local.yml
│   ├── backend.local.tf
│   └── .env.local
│
├── modules/
│
├── environments/
│
├── terraform/
│
└── README.md
```

---

## Notes

- Terraform provider authentication may still require mocked credentials depending on provider implementation.
- Some managed cloud services cannot be fully emulated.
- Kubernetes behavior may differ from managed clusters.
- Recommended usage: validate locally → deploy to real cloud.

## 🧪 Local Development & Cloudless Testing

This repository supports **local execution and infrastructure validation without provisioning resources in Azure or Google Cloud**.

The goal of this mode is to enable:

- Local Terraform validation
- Development without cloud costs
- CI/CD smoke testing
- Module testing
- Kubernetes integration testing
- Faster feedback loops
- Offline experimentation

Instead of deploying to cloud providers, local emulators and compatible services are used.

---

## Architecture Overview

```text
Developer Machine
│
├── Docker Compose
│
├── Terraform
│
├── Local Cloud Emulators
│   │
│   ├── Azure Layer
│   │     ├── Azurite (Storage)
│   │     └── Kind (AKS replacement)
│   │
│   └── GCP Layer
│         ├── Fake GCS
│         ├── Pub/Sub Emulator
│         └── Firestore Emulator
│
├── Kubernetes (Kind)
│
└── Local Terraform Backend
```

---

## Supported Services

| Cloud Provider | Cloud Service | Local Replacement |
|---|---|---|
| Azure | Storage Account | Azurite |
| Azure | AKS | Kind |
| GCP | Cloud Storage | Fake GCS |
| GCP | Pub/Sub | Pub/Sub Emulator |
| GCP | Firestore | Firestore Emulator |
| Any | Terraform Backend | Local Backend |

> This environment is intended for development and validation. It is not a full cloud emulator.

---

## Prerequisites

Install the following tools:

### Required

- Docker
- Docker Compose
- Terraform >= 1.8
- kubectl
- Kind

Verify:

```bash
docker --version
terraform --version
kubectl version --client
kind version
```

---

## Clone Repository

```bash
git clone https://github.com/mjpinot/ha-gcp-azure-terraform

cd ha-gcp-azure-terraform
```

---

## Create Local Environment

Create:

```text
local/docker-compose.local.yml
```

```yaml
services:

  azurite:
    image: mcr.microsoft.com/azure-storage/azurite
    restart: unless-stopped

    ports:
      - "10000:10000"

  fake-gcs:
    image: fsouza/fake-gcs-server

    command:
      - -scheme
      - http

    ports:
      - "4443:4443"

  pubsub:
    image: messagebird/gcloud-pubsub-emulator

    ports:
      - "8681:8681"

  firestore:
    image: mtlynch/firestore-emulator

    ports:
      - "8080:8080"
```

Start services:

```bash
docker compose \
-f local/docker-compose.local.yml \
up -d
```

Validate:

```bash
docker ps
```

---

## Create Local Kubernetes Cluster

Start a local Kubernetes cluster:

```bash
kind create cluster \
--name ha-local
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
NAME
ha-local-control-plane
```

---

## Configure Terraform Local Backend

Create:

```text
local/backend.local.tf
```

```hcl
terraform {

  backend "local" {
    path = "./terraform.tfstate"
  }

}
```

Initialize:

```bash
terraform init
```

---

## Configure Local Environment Variables

Create:

```text
local/.env.local
```

```bash
USE_LOCALSTACK=true

AZURE_STORAGE_ENDPOINT=http://localhost:10000

GCS_ENDPOINT=http://localhost:4443

PUBSUB_EMULATOR_HOST=localhost:8681

FIRESTORE_EMULATOR_HOST=localhost:8080
```

Load variables:

### Linux / macOS

```bash
export $(cat local/.env.local | xargs)
```

### Windows PowerShell

```powershell
Get-Content local/.env.local |
foreach {
  $name,$value=$_.split('=')
  set-item env:$name $value
}
```

---

## Validate Terraform

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Preview:

```bash
terraform plan
```

Expected:

```text
No cloud resources created
```

---

## Apply Locally

```bash
terraform apply \
-auto-approve
```

Verify:

```bash
kubectl get all
```

---

## Cleanup

Destroy infrastructure:

```bash
terraform destroy \
-auto-approve
```

Delete cluster:

```bash
kind delete cluster \
--name ha-local
```

Stop emulators:

```bash
docker compose \
-f local/docker-compose.local.yml \
down
```

---

## CI/CD Example

Create:

```text
.github/workflows/local-validation.yml
```

```yaml
name: Local Validation

on:

  pull_request:

jobs:

  terraform:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Start Local Services
        run: |
          docker compose \
          -f local/docker-compose.local.yml \
          up -d

      - name: Init
        run: terraform init

      - name: Validate
        run: terraform validate

      - name: Plan
        run: terraform plan
```

---

## Recommended Repository Structure

```text
ha-gcp-azure-terraform/

├── local/
│   ├── docker-compose.local.yml
│   ├── backend.local.tf
│   └── .env.local
│
├── modules/
│
├── environments/
│
├── terraform/
│
└── README.md
```

---

## Notes

- Terraform provider authentication may still require mocked credentials depending on provider implementation.
- Some managed cloud services cannot be fully emulated.
- Kubernetes behavior may differ from managed clusters.
- Recommended usage: validate locally → deploy to real cloud.

