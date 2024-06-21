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

variable "network_subnet" {
  type        = string
  description = "AWS Subnet ID"
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
}

variable "instance_ami" {
  type        = string
  description = "EC2 instance image ID"
}

variable "instance_ami_owner" {
  type        = string
  description = "EC2 instance image owner"
}

variable "instance_userdata" {
  type        = string
  description = "EC2 instance user data (base64 encoded)"
  default     = "User data"
}

variable "instance_profile" {
  type        = string
  description = "EC2 instance profile"
}

variable "instance_keypair" {
  type        = string
  description = "EC2 instance keypair"
}

################################################################################
# Volume
################################################################################

variable "volume_type" {
  type        = string
  description = "EC2 volume type"
  default     = "gp3"
}

variable "volume_size" {
  type        = string
  description = "EC2 volume size"
  default     = 32
}
