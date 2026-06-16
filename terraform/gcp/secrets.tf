# ── GCP Service Account for CSI Secret Manager access ────────────────────────

resource "google_service_account" "csi" {
  account_id   = "sa-csi-secrets"
  display_name = "CSI Secret Manager SA"
}

resource "google_project_iam_member" "csi_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.csi.email}"
}

# Workload Identity binding — api service account
resource "google_service_account_iam_member" "csi_api_wi" {
  service_account_id = google_service_account.csi.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[api/sa-api]"
}

# Workload Identity binding — postgres service account
resource "google_service_account_iam_member" "csi_postgres_wi" {
  service_account_id = google_service_account.csi.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[postgres/sa-postgres]"
}

# ── GCP Secrets (placeholders — set real values out-of-band) ─────────────────

resource "google_secret_manager_secret" "postgres_password" {
  secret_id = "postgres-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "api_secret_key" {
  secret_id = "api-secret-key"
  replication {
    auto {}
  }
}

# ── SecretProviderClass — api namespace ───────────────────────────────────────

resource "kubernetes_manifest" "spc_api" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "gcp-sm-api"
      namespace = "api"
    }
    spec = {
      provider = "gcp"
      parameters = {
        secrets = yamlencode([
          { resourceName = "projects/${var.project_id}/secrets/api-secret-key/versions/latest", fileName = "api-secret-key" },
        ])
      }
    }
  }

  depends_on = [module.k8s_apps]
}

# ── SecretProviderClass — postgres namespace ──────────────────────────────────

resource "kubernetes_manifest" "spc_postgres" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "gcp-sm-postgres"
      namespace = "postgres"
    }
    spec = {
      provider = "gcp"
      parameters = {
        secrets = yamlencode([
          { resourceName = "projects/${var.project_id}/secrets/postgres-password/versions/latest", fileName = "postgres-password" },
        ])
      }
    }
  }

  depends_on = [module.k8s_apps]
}
