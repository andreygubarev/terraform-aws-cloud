output "instance_network_interface" {
  value = aws_instance.this.primary_network_interface_id
}

output "instance_ipv4_public" {
  value = aws_instance.this.public_ip
}

output "instance_ipv4_private" {
  value = aws_instance.this.private_ip
}

output "instance_ipv6" {
  value = aws_instance.this.ipv6_addresses[0]
}

output "instance_id" {
  value = aws_instance.this.id
}
