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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
  default     = {}
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

variable "instance_launch_template" {
  type = object({
    id      = string
    version = string
  })
  description = "EC2 instance launch template"
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
