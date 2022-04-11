variable "tfe" {
  type = object({
    organization = string
    token        = string
  })
  sensitive = true
}

variable "github" {
  type = object({
    organization = string
    oauth_token  = string
  })
  sensitive = true
}

provider "tfe" {
  token = var.tfe.token
}

provider "github" {
  owner = var.github.organization
  token = var.github.oauth_token
}

resource "tfe_oauth_client" "github" {
  name             = "github"
  organization     = var.tfe.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github.oauth_token
  service_provider = "github"
}

resource "tfe_workspace" "tfe_run_wait_demo" {
  name         = "tfe-run-wait-demo"
  organization = var.tfe.organization
  vcs_repo {
    identifier     = "binxio/tfe-run-wait-demo"
    branch         = "main"
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_team" "tfe_run_wait_demo" {
  name         = "tfe-run-wait-demo"
  organization = var.tfe.organization
}

resource "tfe_team_token" "tfe_run_wait_demo" {
  team_id = tfe_team.tfe_run_wait_demo.id
}

resource "tfe_team_access" "tfe_run_wait_demo" {
  team_id      = tfe_team.tfe_run_wait_demo.id
  workspace_id = tfe_workspace.tfe_run_wait_demo.id
  permissions {
    runs              = "apply"
    sentinel_mocks    = "none"
    state_versions    = "none"
    variables         = "none"
    workspace_locking = false
  }
}

data "github_repository" "tfe_run_wait_demo" {
  full_name = tfe_workspace.tfe_run_wait_demo.vcs_repo[0].identifier
}

resource "github_actions_secret" "tfe_api_token" {
  repository      = data.github_repository.tfe_run_wait_demo.name
  secret_name     = "TFE_API_TOKEN"
  plaintext_value = tfe_team_token.tfe_run_wait_demo.token
}

resource "github_actions_secret" "tfe_organization" {
  repository      = data.github_repository.tfe_run_wait_demo.name
  secret_name     = "TFE_ORGANIZATION"
  plaintext_value = var.tfe.organization
}