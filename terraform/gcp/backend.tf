terraform {
  backend "gcs" {
    # bucket set via -backend-config="bucket=<state_bucket>" at init time
    prefix = "terraform/gcp"
  }
}
