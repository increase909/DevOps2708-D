provider "gitlab" {
  base_url = var.base_url
  token    = var.gitlab_token
}

module "gitlab_group" {
  source             = "./modules/gitlab-group"
  group_name         = "05-terraform-group"
  project_names      = var.project_names
  create_deploy_token = true  # Указали явно, создаем ли токен
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
