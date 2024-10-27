variable "gitlab_token" {
  type        = string
  description = "token to git"
}
variable "lfs_enabled" {
  type        = bool
  description = "enable_LFS"
  default     = true
}
variable "base_url" {
  type        = string
  description = "baseURL"
  default     = "http://gitlab.loc/api/v4"

}


variable "gitlab_group" {
  type = list(object({
    name        = string
    description = string
    lfs_enabled = bool
  }))
  default = [
    {
      description = "dev_infra"
      name        = "dev_infra"
      lfs_enabled = true
    },
    {
      description = "dev_app"
      name        = "dev_app"
      lfs_enabled = true
    }
  ]
}

variable "project_names" {
  type        = list(string)
  description = "List of project names"
  default     = ["defaultproject"] # Значение по умолчанию
}