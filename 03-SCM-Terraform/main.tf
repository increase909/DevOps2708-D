provider "gitlab" {
  base_url = var.base_url
  token = var.gitlab_token
}
resource "gitlab_group" "dev08_group" {
  name        = "dev08TF" 
  path        = "dev08TF"
  description = "created via Terraform groups dev08"
  visibility_level = "public"     
  lfs_enabled = var.lfs_enabled
}
resource "gitlab_project" "dev08_poject" {
  name        = "dev08"
  namespace_id = gitlab_group.dev08_group.id   
  description = " created via Terraform project dev08"
  visibility_level = "public"
  initialize_with_readme = true
}
resource "gitlab_project_access_token" "dev08_token" {
  project          = gitlab_project.dev08_poject.id   
  name             = "example-token"
  scopes           = ["api", "write_repository"]
  access_level     = "maintainer"
  expires_at       = "2024-12-31"
}
resource "gitlab_group_variable" "group_variable" {
  group        = gitlab_group.dev08_group.id    
  key          = "Jira_token"
  value        = "dsfhisdifhsdhg212"
  protected    = false
  masked       = false
  #environment_scope = "*"
}
terraform {
  backend "s3" {
    bucket                      = "miniolab"
    key                         = "terraform/state"
    region                      = "eu-west-1"
    endpoint                    = "http://192.168.0.197:9000" 
    access_key                  = "minioadmin"
    secret_key                  = "minioadmin"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    skip_requesting_account_id  = true
  }
}