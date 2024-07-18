variable "name" {
  type        = string
  description = "Name of the AWS VPC"

  validation {
    condition     = length(var.name) >= 4 && length(var.name) <= 16
    error_message = "name must be 4-16 characters long, while it is ${length(var.name)}"
  }

  validation {
    condition     = can(regex("^([a-zA-Z])([a-zA-Z0-9-]*)$", var.name))
    error_message = "name must start with a character, and include only characters, digits, and dashes"
  }
}

################################################################################
# Network
################################################################################

variable "network_vpc" {
  type        = string
  description = "AWS VPC ID"
}

variable "network_subnets" {
  type        = list(string)
  description = "AWS Subnet ID"
}

variable "network_security_groups" {
  type        = list(string)
  description = "AWS Security Group IDs"
  default     = []
}

################################################################################
# Instance
################################################################################

variable "instance_launch_template" {
  type = object({
    id      = string
    version = string
  })
  description = "EC2 instance launch template (optional)"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (optional if launch template is provided)"
  default     = null
  validation {
    condition     = var.instance_type != null || var.instance_launch_template != null
    error_message = "either instance_type or instance_launch_template must be provided"
  }
}

variable "instance_ami" {
  type        = string
  description = "EC2 instance image ID (optional if launch template is provided)"
  default     = null
  validation {
    condition     = var.instance_ami != null || var.instance_launch_template != null
    error_message = "either instance_ami or instance_launch_template must be provided"
  }
}

variable "instance_profile" {
  type        = string
  description = "EC2 instance profile (optional)"
  default     = null
}

variable "instance_keypair" {
  type        = string
  description = "EC2 instance keypair (optional)"
  default     = null
}

variable "instance_userdata" {
  type        = string
  description = "EC2 instance user data (optional)"
  default     = null
}

################################################################################
# Volume
################################################################################

variable "volume_type" {
  type        = string
  description = "EC2 instance root volume type"
  default     = null
}

variable "volume_size" {
  type        = string
  description = "EC2 instance root volume size"
  default     = null
}

variable "volume_devices" {
  type = map(object({
    volume_type = string
    volume_size = string
  }))

  description = "EC2 instance additional EBS volumes"
  default     = {}
}
