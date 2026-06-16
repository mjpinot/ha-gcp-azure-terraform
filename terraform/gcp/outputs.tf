output "kube_config_command" {
  value = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}
output "ingress_ip" { value = module.k8s_apps.ingress_ip }
