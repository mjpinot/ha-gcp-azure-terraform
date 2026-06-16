terraform {
  required_version = ">= 1.6"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.33"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sthatfstate"
    container_name       = "tfstate"
    key                  = "cloudflare.tfstate"
    use_oidc             = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
