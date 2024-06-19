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

variable "network_availability_zones" {
  type        = list(string)
  description = "AWS availability zones for the VPC"
}

locals {
  network_availability_zones = sort(var.network_availability_zones)
}

variable "network_cidr" {
  type        = string
  description = "CIDR block for the VPC"

  validation {
    condition     = can(cidrnetmask(var.network_cidr))
    error_message = "network_cidr must be a valid CIDR block"
  }

  validation {
    condition     = can(regex("^(10|172|192\\.)", var.network_cidr))
    error_message = "network_cidr must be a private CIDR block"
  }

  validation {
    condition     = can(regex("/16$", var.network_cidr))
    error_message = "network_cidr must be a /16 CIDR block"
  }
}
