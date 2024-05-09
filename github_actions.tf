resource "google_service_account" "github_actions" {
  project      = var.project
  account_id   = var.github_actions_sa_name
  display_name = var.github_actions_sa_name
  description  = "link to Workload Identity Pool used by GitHub Actions"
}

resource "google_project_iam_member" "github_actions" {
  project = var.project
  for_each = {
    for role in var.github_actions_roles : role => role
  }
  role   = each.value
  member = google_service_account.github_actions.member
}

module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.project
  pool_id     = var.gh_oidc_pool_id
  provider_id = var.gh_oidc_provider_id
  sa_mapping = {
    "github-actions" = {
      sa_name   = google_service_account.github_actions.id
      attribute = "attribute.repository/${var.github_owner}/${var.github_repository}"
    }
  }
}
