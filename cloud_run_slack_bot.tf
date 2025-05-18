// Cloud Run for backend server for Slack app
module "cloud_run_slack_bot" {
  count   = var.create_cloud_run_slack_bot ? 1 : 0
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = ">= 0.17.0"

  # Required variables
  service_name = var.cloud_run_slack_bot_service_name
  project_id   = var.project
  location     = var.region
  image        = var.cloud_run_slack_bot_image

  env_vars = [
    {
      name  = "PROJECT"
      value = var.project
    },
    {
      name  = "REGION"
      value = var.region
    },
    {
      name  = "SLACK_BOT_TOKEN"
      value = var.slack_bot_token // TODO: enable to read from GSM
    },
    {
      name  = "SLACK_CHANNEL"
      value = var.slack_channel
    },
    {
      name  = "SLACK_APP_MODE"
      value = "http"
    },
    {
      name  = "TMP_DIR"
      value = "/tmp"
    },
  ]

  # Optional variables
  service_account_email = google_service_account.cloud_run_slack_bot[0].email
}

resource "google_service_account" "cloud_run_slack_bot" {
  count        = var.create_cloud_run_slack_bot ? 1 : 0
  account_id   = "cloud-run-slack-bot"
  display_name = "cloud-run-slack-bot"
}


# Audit logging + Log Sink + PubSub
# Audit loggs: Admin Activity audit logs are always written; you can't configure, exclude, or disable them. (enough) https://cloud.google.com/logging/docs/audit
# https://cloud.google.com/pubsub/docs/audit-logging

# pub/sub topic 作成
resource "google_pubsub_topic" "cloud_run_audit_log" {
  count = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  name  = "cloud-run-audit-log"
}

# pub/sub topic に Sink.WriterIDをpubsub publisher権限で追加
# projectIAMに追加する方法もあるが、権限の影響範囲を絞るためにTopicに追加する
resource "google_pubsub_topic_iam_member" "log_writer" {
  count   = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  project = google_pubsub_topic.cloud_run_audit_log[0].project
  topic   = google_pubsub_topic.cloud_run_audit_log[0].name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.cloud_run_audit_log[0].writer_identity
}

# Log Router Sinkを作成
resource "google_logging_project_sink" "cloud_run_audit_log" {
  count                  = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  name                   = "cloud_run_audit_log"
  destination            = "pubsub.googleapis.com/projects/${google_pubsub_topic.cloud_run_audit_log[0].project}/topics/${google_pubsub_topic.cloud_run_audit_log[0].name}"
  filter                 = "resource.type = cloud_run_revision AND (logName = projects/${var.project}/logs/cloudaudit.googleapis.com%2Factivity OR logName = projects/${var.project}/logs/cloudaudit.googleapis.com%2Fsystem_event)"
  unique_writer_identity = true
}

# Pubsub -> Cloud Run https://cloud.google.com/run/docs/triggering/pubsub-push?hl=ja

# https://cloud.google.com/run/docs/tutorials/pubsub#terraform_2
resource "google_service_account" "sa" {
  count        = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  count    = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "project_token_creator" {
  count   = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  project = var.project
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub_agent[0].email}"]
}

resource "google_pubsub_subscription" "subscription" {
  count = var.enable_cloud_run_slack_bot_audit_log_notification ? 1 : 0
  name  = "pubsub_subscription"
  topic = google_pubsub_topic.cloud_run_audit_log[0].name
  push_config {
    push_endpoint = "${module.cloud_run_slack_bot[0].service_url}/cloudrun/events" # defined in the cloud-run-slack-bot app
    oidc_token {
      service_account_email = google_service_account.sa[0].email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}
