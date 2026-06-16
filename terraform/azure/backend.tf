terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sthatfstate"
    container_name       = "tfstate"
    key                  = "azure.tfstate"
    use_oidc             = true
  }
}
