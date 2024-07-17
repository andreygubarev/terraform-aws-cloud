################################################################################
# AWS EC2 Instance
################################################################################

resource "aws_instance" "this" {
  instance_type = data.aws_ec2_instance_type.this.instance_type
  ami           = data.aws_ami.this.id

  key_name             = data.aws_key_pair.this.key_name
  iam_instance_profile = data.aws_iam_instance_profile.this.name
  user_data_base64     = base64encode(var.instance_userdata)

  monitoring = true

  subnet_id              = data.aws_subnet.this.id
  vpc_security_group_ids = data.aws_security_groups.this.ids

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
