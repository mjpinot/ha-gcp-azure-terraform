output "kube_config_command" {
  value = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name}"
}
output "ingress_ip" { value = module.k8s_apps.ingress_ip }
output "key_vault_name" { value = azurerm_key_vault.main.name }
