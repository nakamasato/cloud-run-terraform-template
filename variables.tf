variable "project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
  default     = "asia-northeast1"
}

variable "multi_regions" {
  description = "The regions to create Cloud Run in"
  type        = list(string)
  default     = ["asia-northeast1"]
}

### Cloud Run config start ###
variable "image" {
  description = "The container image to deploy to Cloud Run"
  type        = string
  default     = "gcr.io/cloudrun/hello:latest"
}

variable "service_name" {
  description = "The name of the Cloud Run service. This is also used as the name of the service account."
  type        = string
}

variable "slack_bot_token" {
  description = "The Slack bot token"
  default     = ""
  type        = string
  sensitive   = true
}

variable "slack_channel" {
  description = "The Slack channel to post messages to"
  default     = ""
  type        = string
}

### Cloud Run config end ###

### cloud-run-slack-bot config start ###

variable "create_cloud_run_slack_bot" {
  description = "Whether to create the Cloud Run Slack bot. https://github.com/nakamasato/cloud-run-slack-bot"
  type        = bool
  default     = false
}

variable "cloud_run_slack_bot_image" {
  description = "The container image to deploy to Cloud Run for the Slack bot"
  type        = string
  default     = "nakamasato/cloud-run-slack-bot:latest"
}

variable "cloud_run_slack_bot_service_name" {
  description = "The name of the Cloud Run service for the Slack bot"
  type        = string
  default     = "cloud-run-slack-bot"
}

variable "enable_cloud_run_slack_bot_audit_log_notification" {
  description = "Whether to enable audit log notification for the Cloud Run Slack bot"
  type        = bool
  default     = false
}

### cloud-run-slack-bot config end ###

### GitHub Actions config start ###

variable "github_actions_sa_name" {
  description = "The name of the service account for GitHub Actions"
  type        = string
  default     = "github-actions"
}

variable "github_owner" {
  description = "The owner of the GitHub repository"
  type        = string
}

variable "github_repository" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "gh_oidc_pool_id" {
  description = "The ID of the Workload Identity Pool used by GitHub Actions"
  type        = string
  default     = "github-actions"
}

variable "gh_oidc_provider_id" {
  description = "The ID of the OIDC provider used by GitHub Actions"
  type        = string
  default     = "github-actions"
}

variable "github_actions_roles" {
  description = "The roles to grant to the GitHub Actions service account"
  type        = list(string)
  default = [
    "roles/serviceusage.serviceUsageViewer", # To allow GitHub Actions to list services `serviceusage.services.list`
    "roles/iam.workloadIdentityPoolViewer",  # To allow GitHub Actions to use Workload Identity `iam.workloadIdentityPools.get`
    "roles/iam.serviceAccountAdmin",         # To manage other service account
    "roles/resourcemanager.projectIamAdmin", # GitHub Actions identity
    "roles/run.developer",                   # To allow GitHub Actions to deploy to Cloud Run
    "roles/storage.objectUser",              # GitHub Actions needs write/read permission for GCS to manage terraform state file
  ]
}
