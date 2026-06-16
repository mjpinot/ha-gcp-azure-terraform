variable "cloud_provider" {
  description = "Cloud provider: azure or gcp"
  type        = string
  validation {
    condition     = contains(["azure", "gcp"], var.cloud_provider)
    error_message = "Must be azure or gcp."
  }
}

variable "workload_identity_annotation_value" {
  description = "Value for the Workload Identity annotation on service accounts"
  type        = string
}
