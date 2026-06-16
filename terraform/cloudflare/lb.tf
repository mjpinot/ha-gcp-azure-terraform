# Health monitor — checks /healthz on each origin every 60 s
resource "cloudflare_load_balancer_monitor" "healthz" {
  account_id     = var.cloudflare_account_id
  type           = "http"
  path           = "/healthz"
  interval       = 60
  timeout        = 5
  retries        = 2
  expected_codes = "200"
  description    = "HA app healthz check"

  header {
    header = "Host"
    values = [var.hostname]
  }
}

# Primary origin pool — AKS
resource "cloudflare_load_balancer_pool" "azure" {
  account_id  = var.cloudflare_account_id
  name        = "azure-primary"
  description = "AKS ingress — primary"
  monitor     = cloudflare_load_balancer_monitor.healthz.id

  origins {
    name    = "aks"
    address = var.azure_ingress_ip
    enabled = true
  }
}

# Fallback origin pool — GKE
resource "cloudflare_load_balancer_pool" "gcp" {
  account_id  = var.cloudflare_account_id
  name        = "gcp-fallback"
  description = "GKE ingress — standby"
  monitor     = cloudflare_load_balancer_monitor.healthz.id

  origins {
    name    = "gke"
    address = var.gke_ingress_ip
    enabled = true
  }
}

# Load balancer — always routes to azure-primary; fails over to gcp-fallback
resource "cloudflare_load_balancer" "main" {
  zone_id         = var.cloudflare_zone_id
  name            = var.hostname
  description     = "HA multi-cloud LB"
  proxied         = true
  steering_policy = "off" # ordered failover

  default_pool_ids = [cloudflare_load_balancer_pool.azure.id]
  fallback_pool_id = cloudflare_load_balancer_pool.gcp.id
}
