resource "helm_release" "cnpg" {
  name             = "cloudnative-pg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = var.operator_version
  namespace        = "cnpg-system"
  create_namespace = true
}
