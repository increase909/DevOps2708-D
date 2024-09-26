variable "gitlab_token" {
  type = string
  description = "token to git"
}
variable "lfs_enabled" {
    type = bool
    description = "enable_LFS"
    default = true
}
variable "base_url" {
    type = string
    description = "baseURL"
    default = "http://gitlab.loc/api/v4" 
    
}