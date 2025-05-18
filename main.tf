resource "google_cloud_run_v2_service" "default" {
  for_each = toset(var.multi_regions)

  name     = var.service_name
  location = each.value

  template {
    containers {
      image = var.image
    }

    service_account = google_service_account.cloud_run.email

    annotations = var.template_annotations
  }

  project = var.project
}

resource "google_service_account" "cloud_run" {
  account_id   = var.service_name
  display_name = var.service_name
}
