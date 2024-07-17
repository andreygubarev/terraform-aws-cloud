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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources"
  default     = {}
}

################################################################################
# Network
################################################################################

variable "network_vpc" {
  type        = string
  description = "AWS VPC ID"
}

variable "network_security_groups" {
  type        = list(string)
  description = "AWS Security Group IDs"
}

################################################################################
# Instance
################################################################################

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = null
}

variable "instance_ami" {
  type        = map(string)
  description = "EC2 instance image ID (filters provided by 'describe-images' API)"
}

variable "instance_profile" {
  type        = string
  description = "EC2 instance profile"
}

variable "instance_keypair" {
  type        = string
  description = "EC2 instance keypair"
}

variable "instance_userdata" {
  type        = string
  description = "EC2 instance user data"
  default     = null
}

################################################################################
# Volume
################################################################################

variable "volume_type" {
  type        = string
  description = "EC2 instance root volume type"
  default     = "gp3"
}

variable "volume_size" {
  type        = string
  description = "EC2 instance root volume size"
  default     = 8
}
