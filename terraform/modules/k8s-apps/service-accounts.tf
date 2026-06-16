locals {
  wi_annotation = var.cloud_provider == "azure" ? "azure.workload.identity/client-id" : "iam.gke.io/gcp-service-account"
}

resource "kubernetes_service_account" "api" {
  metadata {
    name      = "sa-api"
    namespace = kubernetes_namespace.api.metadata[0].name
    annotations = {
      (local.wi_annotation) = var.workload_identity_annotation_value
    }
  }
}

resource "kubernetes_service_account" "postgres" {
  metadata {
    name      = "sa-postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
    annotations = {
      (local.wi_annotation) = var.workload_identity_annotation_value
    }
  }
}

resource "kubernetes_service_account" "frontend" {
  metadata {
    name      = "sa-frontend"
    namespace = kubernetes_namespace.frontend.metadata[0].name
  }
}
