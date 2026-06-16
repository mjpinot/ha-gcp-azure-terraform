# ── Managed Identity for CSI driver ──────────────────────────────────────────

resource "azurerm_user_assigned_identity" "csi" {
  name                = "mi-csi-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "csi_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.csi.principal_id
}

# Federated credential: binds the Azure MI to the k8s service account
resource "azurerm_federated_identity_credential" "api" {
  name                = "fedcred-api"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.csi.id
  subject             = "system:serviceaccount:api:sa-api"
}

resource "azurerm_federated_identity_credential" "postgres" {
  name                = "fedcred-postgres"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.csi.id
  subject             = "system:serviceaccount:postgres:sa-postgres"
}

# ── Placeholder secrets in Key Vault ─────────────────────────────────────────
# Real values must be set out-of-band; these create the secret slots.

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = "REPLACE_ME"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform]

  lifecycle { ignore_changes = [value] }
}

resource "azurerm_key_vault_secret" "api_secret_key" {
  name         = "api-secret-key"
  value        = "REPLACE_ME"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform]

  lifecycle { ignore_changes = [value] }
}

# ── SecretProviderClass — api namespace ───────────────────────────────────────

resource "kubernetes_manifest" "spc_api" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kv-api"
      namespace = "api"
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity       = "false"
        useVMManagedIdentity = "false"
        clientID             = azurerm_user_assigned_identity.csi.client_id
        keyvaultName         = azurerm_key_vault.main.name
        tenantId             = var.tenant_id
        objects = yamlencode([
          { objectName = "api-secret-key", objectType = "secret" },
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
      name      = "azure-kv-postgres"
      namespace = "postgres"
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity       = "false"
        useVMManagedIdentity = "false"
        clientID             = azurerm_user_assigned_identity.csi.client_id
        keyvaultName         = azurerm_key_vault.main.name
        tenantId             = var.tenant_id
        objects = yamlencode([
          { objectName = "postgres-password", objectType = "secret" },
        ])
      }
    }
  }

  depends_on = [module.k8s_apps]
}
