################################################################################
# AWS EC2 Instance
################################################################################

resource "aws_instance" "this" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  key_name             = var.instance_keypair
  iam_instance_profile = var.instance_profile
  user_data_base64     = var.instance_userdata

  monitoring = true

  subnet_id              = var.network_subnet
  vpc_security_group_ids = var.network_security_groups

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "resource-name"
  }

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true

    tags = {
      Name = var.name
    }
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    ignore_changes = [
      vpc_security_group_ids,
    ]
  }
}
