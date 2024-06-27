variable "name" {
  type        = string
  description = "Name of the resources"

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
  description = "VPC ID to allocate the resources"
}

variable "network_subnets" {
  type        = list(string)
  description = "Subnet IDs to allocate the resources"
}

variable "network_security_groups" {
  type        = list(string)
  description = "Security Group IDs to attach to the EC2 instances"
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

variable "instance_user_data" {
  type        = string
  description = "EC2 instance user data"
  default     = "Path to the user data file"
}

variable "instance_profile_policies" {
  type        = list(string)
  description = "EC2 instance profile policies"
  default     = []
}

variable "instance_keypair_algoirthm" {
  type        = string
  description = "EC2 instance keypair algorithm"
  default     = "ED25519"
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

################################################################################
# Group
################################################################################

variable "group_capacity_min" {
  type        = string
  description = "Minimum number of instances in the autoscaling group"
}

variable "group_capacity_max" {
  type        = string
  description = "Maximum number of instances in the autoscaling group"
}

variable "group_timeout_cooldown" {
  type        = string
  description = "Cooldown period in seconds"
  default     = 60
}

variable "group_timeout_grace_period" {
  type        = string
  description = "Grace period in seconds"
  default     = 60
}

variable "group_timeout_heartbeat" {
  type        = string
  description = "Cloud-init heartbeat timeout in seconds"
  default     = 120
}

variable "group_instance_refresh" {
  type        = bool
  description = "Enable instance refresh"
  default     = false
}

variable "group_notification_topic" {
  type        = string
  description = "SNS topic to send notifications"
  default     = ""
}
