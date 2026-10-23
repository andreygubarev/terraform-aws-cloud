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

variable "network_cidr_ipv4" {
  type        = string
  description = "Private IPv4 /16 CIDR block for the VPC"

  validation {
    condition     = can(cidrnetmask(var.network_cidr_ipv4))
    error_message = "network_cidr_ipv4 must be a valid IPv4 CIDR block"
  }

  validation {
    condition     = can(regex("^(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.)", var.network_cidr_ipv4))
    error_message = "network_cidr_ipv4 must be within 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16"
  }

  validation {
    condition     = can(regex("/16$", var.network_cidr_ipv4))
    error_message = "network_cidr_ipv4 must be a /16 CIDR block"
  }

  validation {
    condition     = try(cidrhost(var.network_cidr_ipv4, 0) == split("/", var.network_cidr_ipv4)[0], false)
    error_message = "network_cidr_ipv4 must use the network address, for example 10.0.0.0/16 instead of 10.0.1.0/16"
  }
}

variable "network_cidr_ipv6" {
  type        = bool
  description = "Enable IPv6 CIDR block for the VPC (auto-generated)"
  default     = true
}

variable "network_dns" {
  type        = list(string)
  description = "DNS servers for the VPC over DHCP Options"
  default     = ["AmazonProvidedDNS"]
}

variable "enable_public_subnets" {
  type        = bool
  description = "Enable public subnets"
  default     = true
}

variable "enable_private_subnets" {
  type        = bool
  description = "Enable private subnets"
  default     = true
}

variable "enable_public_ipv4" {
  type        = bool
  description = "Enable public IPv4"
  default     = true
}

variable "enable_public_ipv6" {
  type        = bool
  description = "Enable public IPv6"
  default     = true
}

variable "enable_dns64" {
  type        = bool
  description = "Enable DNS64 for IPv6"
  default     = false
}

variable "enable_nat64" {
  type        = bool
  description = "Enable NAT64 for IPv6"
  default     = false
}

variable "enable_gateway_vpc_endpoints" {
  type        = bool
  description = "Enable Gateway VPC endpoint for S3 and DynamoDB"
  default     = true
}
