variable "project_name" {
  type        = string
  description = "Project name for resource naming"
  validation {
    condition     = length(var.project_name) > 5
    error_message = "The project_name must be longer than 5 characters."
  }
}

variable "environment_name" {
  type        = string
  description = "Environment name (dev, uat, prod)"
  validation {
    condition     = var.environment_name == "dev" || var.environment_name == "uat" || var.environment_name == "prod"
    error_message = "The environment_name must be one of 'dev', 'uat', or 'prod'."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type, limited to 't' types only"
  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "The instance_type must be one of the allowed 't' types (e.g., 't2.micro', 't2.small')."
  }
}

variable "monitoring" {
  type        = bool
  description = "Monitoring must be enabled (true)"
  validation {
    condition     = var.monitoring == true
    error_message = "The monitoring variable must be true."
  }
}

variable "root_block_device_size" {
  type        = number
  description = "Root block device size, must be between 10 and 30 GB"
  validation {
    condition     = var.root_block_device_size >= 10 && var.root_block_device_size < 30
    error_message = "The root_block_device_size must be between 10 and 30 GB."
  }
}

variable "ebs_block_device_size" {
  type        = number
  description = "EBS block device size, must be between 10 and 30 GB"
  validation {
    condition     = var.ebs_block_device_size >= 10 && var.ebs_block_device_size < 30
    error_message = "The ebs_block_device_size must be between 10 and 30 GB."
  }
}

variable "environment_owner" {
  type        = string
  description = "Email of the environment owner"
  validation {
    condition     = can(regex("^\\S+@\\S+\\.\\S+$", var.environment_owner))
    error_message = "The environment_owner must be a valid email address."
  }
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance. If left empty, the latest Ubuntu AMI will be used."
  type        = string
  default     = ""

  validation {
    condition = can(regex("^ami-[0-9a-fA-F]{8,17}$", var.ami_id)) || var.ami_id == ""
    error_message = "The ami_id must follow the AWS AMI ID format, starting with 'ami-' followed by 8 to 17 hexadecimal characters, or be left empty to use the latest Ubuntu AMI."
  }
}

