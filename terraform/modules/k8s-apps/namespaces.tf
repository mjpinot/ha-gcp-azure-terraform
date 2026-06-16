resource "kubernetes_namespace" "frontend" {
  metadata { name = "frontend" }
}

resource "kubernetes_namespace" "api" {
  metadata { name = "api" }
}

resource "kubernetes_namespace" "postgres" {
  metadata { name = "postgres" }
}
