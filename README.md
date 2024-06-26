# cloud-run-terraform-template

This is a module to set up Cloud Run service with Terraform.

This module is a combination of other modules:

1. https://github.com/GoogleCloudPlatform/terraform-google-cloud-run
1. https://github.com/terraform-google-modules/terraform-google-github-actions-runners/tree/v3.1.2/modules/gh-oidc


## Variables

### Required

- `project` - GCP project
- `region` - GCP region
- `multi_regions` - GCP multi regions for Cloud Run service
- `service_name` - Cloud Run service name
- `image` - Docker image for Cloud Run service
- `github_owner` - GitHub owner
- `github_repository` - GitHub repository
- `github_actions_sa_name` - GitHub Actions service account name (default: `github-actions`)
- `gh_oidc_pool_id` - GitHub OIDC pool ID
- `gh_oidc_provider_id` - GitHub OIDC provider ID
- `github_actions_roles` - GitHub Actions roles

### Optional

Cloud Run Slack Bot:

- `create_cloud_run_slack_bot` - Create [cloud-run-slack-bot](github.com/nakamasato/cloud-run-slack-bot) (default: `false`)
- `slack_bot_token` - Slack bot token (TODO: enable to read from GSM) for cloud-run-slack-bot (default: `""`)
- `slack_channel` - Slack channel to post messages for cloud-run-slack-bot (default: `""`)
- `cloud_run_slack_bot_image` - Docker image for cloud-run-slack-bot (default: `nakamasato/cloud-run-slack-bot:latest`)
- `cloud_run_slack_bot_service_name` - Cloud Run service name for cloud-run-slack-bot (default: `cloud-run-slack-bot`)

Cloud Run Slack Bot option (audit log notification)

- `enable_cloud_run_slack_bot_audit_log_notification` - Enable audit log notification for cloud-run-slack-bot (default: `false`)

## Options

- [x] Set up a Cloud Run service in multiple regions. `multi_regions = ["us-central1", "us-west1"]`
- [x] Set up [cloud-run-slack-bot](https://github.com/nakamasato/cloud-run-slack-bot) (optional)
- [x] Set up GitHub Actions to manage Cloud Run.
