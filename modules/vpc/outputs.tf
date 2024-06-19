output "network_vpc" {
  value       = aws_vpc.this.id
  description = "AWS VPC ID"
}

output "network_availability_zones" {
  value       = sort(data.aws_availability_zones.this.names)
  description = "AWS VPC Availability Zones"
}

output "network_public_subnets" {
  value       = [for subnet in sort(data.aws_availability_zones.this.names) : aws_subnet.public[subnet].id]
  description = "AWS VPC Public Subnets"
}

output "network_private_subnets" {
  value       = [for subnet in sort(data.aws_availability_zones.this.names) : aws_subnet.private[subnet].id]
  description = "AWS VPC Private Subnets"
}

output "network_public_ip" {
  value       = [for subnet in sort(data.aws_availability_zones.this.names) : aws_eip.this[subnet].public_ip]
  description = "AWS Public IP"
}

output "network_security_group" {
  value       = data.aws_security_group.this.id
  description = "Default AWS Security Group ID"
}

output "instance_profile" {
  value       = aws_iam_instance_profile.this.name
  description = "AWS Instance Profile Name"
}

output "instance_keypair" {
  value       = aws_key_pair.this.key_name
  description = "AWS Key Pair Name"
}

output "instance_keypair_privkey" {
  value       = tls_private_key.this.private_key_openssh
  description = "AWS Key Pair Private Key"
  sensitive   = true
}
