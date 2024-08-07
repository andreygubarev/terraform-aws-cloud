output "network_vpc" {
  value       = aws_vpc.this.id
  description = "AWS VPC ID"
}

output "network_availability_zones" {
  value       = sort(data.aws_availability_zones.this.names)
  description = "AWS VPC Availability Zones"
}

output "network_public_subnets" {
  value       = local.enable_public_subnets ? [for subnet in sort(data.aws_availability_zones.this.names) : aws_subnet.public[subnet].id] : []
  description = "AWS VPC Public Subnets"
}

output "network_private_subnets" {
  value       = local.enable_private_subnets ? [for subnet in sort(data.aws_availability_zones.this.names) : aws_subnet.private[subnet].id] : []
  description = "AWS VPC Private Subnets"
}

output "network_public_ips" {
  value       = local.enable_subnets ? [for subnet in sort(data.aws_availability_zones.this.names) : aws_eip.this[subnet].public_ip] : []
  description = "AWS Public IP"
}

output "network_security_groups" {
  value       = [data.aws_security_group.this.id]
  description = "Default AWS Security Group ID"
}
