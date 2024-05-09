module "cloud_run" {
  for_each = toset(var.multi_regions)
  source   = "GoogleCloudPlatform/cloud-run/google"
  version  = "~> 0.10.0"

  # Required variables
  service_name = var.service_name
  project_id   = var.project
  location     = each.value
  image        = var.image

  # Optional variables
  service_account_email = google_service_account.cloud_run.email
}

resource "google_service_account" "cloud_run" {
  account_id   = var.service_name
  display_name = var.service_name
}
