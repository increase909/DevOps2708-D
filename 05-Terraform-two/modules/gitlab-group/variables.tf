variable "group_name" {
  type        = string
  description = "Name of the GitLab group"
}

variable "project_names" {
  type        = list(string)
  description = "List of project names"
} 

variable "create_deploy_token" {
  type        = bool
  description = "Whether to create a deploy token"
  default     = false
}
