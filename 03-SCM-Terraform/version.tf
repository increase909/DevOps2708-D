terraform {
  required_version = "1.9.6"
  required_providers {
    gitlab = {
        source = "gitlabhq/gitlab"
        version = "17.3.1"
    }
  }
}
