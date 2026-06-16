# ha-gcp-azure-terraform

Multi-cloud HA Kubernetes platform — AKS (Azure, primary) + GKE (GCP, standby).

## Architecture

- **Traffic:** Cloudflare Load Balancing, active/passive failover (AKS → GKE)
- **Secrets:** Azure Key Vault (AKS) + GCP Secret Manager (GKE) via Secrets Store CSI Driver
- **Database:** CloudNativePG — primary on AKS, streaming replica on GKE
- **Apps:** Node.js frontend + Python API, NGINX ingress, Cloudflare proxied
- **CI/CD:** GitHub Actions, OIDC auth (no stored cloud credentials)

## Prerequisites

- Terraform >= 1.6
- Azure CLI, authenticated (`az login`)
- gcloud CLI, authenticated (`gcloud auth application-default login`)
- kubectl, helm
- Cloudflare account with Load Balancing enabled (paid)
- GitHub repository with Actions enabled

## Directory Layout

```
terraform/
  azure/        # AKS + Key Vault + Azure state backend
  gcp/          # GKE + Secret Manager + GCS state backend
  cloudflare/   # LB pools, health checks, DNS, CDN
  modules/
    k8s-apps/       # shared: NGINX ingress, namespaces, service accounts
    cloudnativepg/  # CloudNativePG operator Helm release
k8s/
  frontend/     # Deployment, Service, HPA
  api/          # Deployment, Service, HPA (CSI secret mount)
  postgres/     # CloudNativePG Cluster manifests (primary + replica)
apps/
  frontend/     # Node.js Express app + Dockerfile
  api/          # Python FastAPI app + Dockerfile
.github/workflows/
  terraform-azure.yml
  terraform-gcp.yml
  terraform-cloudflare.yml
  apps.yml
```

## Deployment Order

1. `terraform/azure/` — provision AKS + Key Vault
2. `terraform/gcp/` — provision GKE
3. `terraform/cloudflare/` — wire LB using outputs from steps 1 & 2
4. Push app images via CI, then `kubectl apply -k k8s/overlays/azure` and `k8s/overlays/gcp`

## Failover Runbook

### Database promotion (GKE becomes primary)
```bash
kubectl cnpg promote pg-replica -n postgres --context <gke-context>
```
Update `DB_HOST` in the API deployment to point to the GKE PostgreSQL service.

### Traffic failover
Cloudflare Load Balancing automatically fails over when the AKS `/healthz` health check fails for the configured threshold. No manual action required.
