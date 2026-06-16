variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" { type = string }
variable "hostname" { type = string }
variable "azure_ingress_ip" { type = string }
variable "gke_ingress_ip" { type = string }
