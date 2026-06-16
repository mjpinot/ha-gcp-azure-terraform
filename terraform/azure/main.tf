data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ── Networking ────────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "main" {
  name                = "vnet-ha-${random_string.suffix.result}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_address]
}

# ── Log Analytics ─────────────────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-ha-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── Key Vault ─────────────────────────────────────────────────────────────────

resource "azurerm_key_vault" "main" {
  name                       = "kv-ha-${random_string.suffix.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# ── AKS ───────────────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.cluster_name
  location                          = azurerm_resource_group.main.location
  resource_group_name               = azurerm_resource_group.main.name
  kubernetes_version                = var.kubernetes_version
  dns_prefix                        = var.cluster_name
  role_based_access_control_enabled = true
  local_account_disabled            = true
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_D2s_v3"
    node_count                   = 2
    vnet_subnet_id               = azurerm_subnet.aks.id
    os_disk_size_gb              = 128
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D4s_v3"
  node_count            = 2
  min_count             = 2
  max_count             = 5
  enable_auto_scaling   = true
  vnet_subnet_id        = azurerm_subnet.aks.id

  node_labels = { workload = "app" }
}

# ── Shared apps module (NGINX ingress, namespaces, service accounts) ──────────

module "k8s_apps" {
  source = "../modules/k8s-apps"

  cloud_provider                     = "azure"
  workload_identity_annotation_value = azurerm_user_assigned_identity.csi.client_id

  depends_on = [azurerm_kubernetes_cluster.main]
}

# ── CloudNativePG operator ────────────────────────────────────────────────────

module "cnpg" {
  source = "../modules/cloudnativepg"

  depends_on = [azurerm_kubernetes_cluster.main]
}
