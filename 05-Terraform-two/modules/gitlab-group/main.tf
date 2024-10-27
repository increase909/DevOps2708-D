terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 17.3.1"
    }
  }
}

# група GitLab
resource "gitlab_group" "group" {
  name               = var.group_name
  path               = var.group_name
  visibility_level   = "public"
  lfs_enabled        = "true"
  description        = "Group created by Terraform"
  project_creation_level = "maintainer"
}

# проект в груп
resource "gitlab_project" "projects" {
  for_each         = toset(var.project_names)
  name             = each.value
  namespace_id     = gitlab_group.group.id
  visibility_level = "public"
  initialize_with_readme = true

  depends_on = [gitlab_group.group] 
}


#  токен для груп
resource "gitlab_deploy_token" "group_token" {
  count              = var.create_deploy_token ? 1 : 0
  group              = gitlab_group.group.id
  name               = "${gitlab_group.group.name}-dt-ro"
  scopes             = ["read_repository"]
  expires_at         = "2025-01-01T00:00:00Z"
}

# токена доступа
resource "gitlab_group_variable" "deploy_group_variable" {
  count              = var.create_deploy_token ? 1 : 0
  group              = gitlab_group.group.id
  key                = "DEPLOY_TOKEN"
  value              = gitlab_deploy_token.group_token[0].token
  protected          = false
  masked             = true
  environment_scope  = "*"
}

