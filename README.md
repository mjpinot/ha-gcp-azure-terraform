# HA Multi-Cloud Infrastructure on Azure + GCP using Terraform

> Production-ready reference architecture for deploying highly available infrastructure across Microsoft Azure and Google Cloud Platform using Terraform.

---

## Architecture

```text
                               ┌─────────────────────────┐
                               │        GitHub           │
                               │   Source + Actions CI   │
                               └──────────┬──────────────┘
                                          │
                                          │ terraform apply
                                          ▼
                ┌────────────────────────────────────────────┐
                │            Terraform Orchestrator          │
                │  Providers: AzureRM + Google + Random      │
                └───────────────┬───────────────┬────────────┘
                                │               │
                  ┌─────────────┘               └─────────────┐
                  ▼                                           ▼

      ┌───────────────────────┐                 ┌────────────────────────┐
      │         Azure         │                 │          GCP           │
      │   Primary Region      │                 │     Secondary Region   │
      ├───────────────────────┤                 ├────────────────────────┤
      │ Resource Group        │                 │ Project                │
      │ Virtual Network       │                 │ VPC Network            │
      │ Subnets               │                 │ Subnets                │
      │ Load Balancer         │                 │ Load Balancer          │
      │ Kubernetes / Compute  │◄──── Failover ─►│ Kubernetes / Compute   │
      │ Monitoring            │                 │ Monitoring             │
      └───────────┬───────────┘                 └──────────┬─────────────┘
                  │                                        │
                  └────────────────┬───────────────────────┘
                                   ▼
                     ┌─────────────────────────┐
                     │      Shared Services    │
                     │ DNS / State / Secrets   │
                     │ Observability / Alerts  │
                     └─────────────────────────┘
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

```text
ha-gcp-azure-terraform/
├── modules/
│   ├── azure/
│   ├── gcp/
│   ├── network/
│   └── monitoring/
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
├── scripts/
├── .github/
│   └── workflows/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
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
