################################################################################
# AWS EC2 Instance
################################################################################

resource "aws_instance" "this" {
  dynamic "launch_template" {
    for_each = var.instance_launch_template != null ? [var.instance_launch_template] : []
    content {
      id      = launch_template.value.id
      version = launch_template.value.version
    }
  }

  instance_type = var.instance_type
  ami           = var.instance_ami

  key_name             = var.instance_keypair
  iam_instance_profile = var.instance_profile
  user_data_base64     = var.instance_userdata != null ? base64encode(var.instance_userdata) : null

  monitoring = true

  subnet_id              = data.aws_subnet.this.id
  vpc_security_group_ids = var.network_security_groups

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = data.aws_subnet.this.enable_resource_name_dns_aaaa_record_on_launch
    enable_resource_name_dns_a_record    = data.aws_subnet.this.enable_resource_name_dns_a_record_on_launch
    hostname_type                        = "resource-name"
  }

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
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

################################################################################
# AWS EBS Volume
################################################################################

resource "aws_ebs_volume" "this" {
  for_each = var.volume_devices

  availability_zone = data.aws_subnet.this.availability_zone
  type              = each.value.volume_type
  size              = each.value.volume_size
  encrypted         = true

  tags = {
    Name = var.name
  }
}

resource "aws_volume_attachment" "this" {
  for_each = var.volume_devices

  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.this[each.key].id
  device_name = each.key
}
