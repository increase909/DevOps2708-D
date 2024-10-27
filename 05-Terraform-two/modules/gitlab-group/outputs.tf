output "group_id" {
  value = gitlab_group.group.id
}

output "group_web_url" {
  description = "group web url" 
  value = gitlab_group.group.web_url
}
output "group_path" {
  value = gitlab_group.group.path
}