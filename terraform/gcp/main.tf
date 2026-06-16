# ── State bucket (bootstrap — apply once with local backend, then migrate) ────

resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning { enabled = true }
}

# ── VPC ───────────────────────────────────────────────────────────────────────

resource "google_compute_network" "main" {
  name                    = "vpc-ha"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name                     = "snet-gke"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# ── GKE Standard ─────────────────────────────────────────────────────────────

resource "google_container_cluster" "main" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.kubernetes_version
  network                  = google_compute_network.main.id
  subnetwork               = google_compute_subnetwork.gke.id
  deletion_protection      = false

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.32/28"
  }

  release_channel { channel = "REGULAR" }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

# System node pool
resource "google_container_node_pool" "system" {
  name       = "system"
  cluster    = google_container_cluster.main.id
  node_count = 2

  node_config {
    machine_type    = "e2-standard-2"
    disk_size_gb    = 100
    service_account = google_service_account.gke_node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config { mode = "GKE_METADATA" }

    taint {
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }
}

# App node pool
resource "google_container_node_pool" "app" {
  name    = "app"
  cluster = google_container_cluster.main.id

  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }

  node_config {
    machine_type    = "e2-standard-4"
    disk_size_gb    = 100
    service_account = google_service_account.gke_node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config { mode = "GKE_METADATA" }

    labels = { workload = "app" }
  }
}

# Node service account (least-privilege)
resource "google_service_account" "gke_node" {
  account_id   = "sa-gke-node"
  display_name = "GKE Node SA"
}

resource "google_project_iam_member" "gke_node_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

resource "google_project_iam_member" "gke_node_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# ── Shared apps module (NGINX ingress, namespaces, service accounts) ──────────

module "k8s_apps" {
  source = "../modules/k8s-apps"

  cloud_provider                     = "gcp"
  workload_identity_annotation_value = "${var.project_id}.svc.id.goog[api/sa-api]"

  depends_on = [google_container_node_pool.app]
}

# ── CloudNativePG operator ────────────────────────────────────────────────────

module "cnpg" {
  source = "../modules/cloudnativepg"

  depends_on = [google_container_node_pool.app]
}
