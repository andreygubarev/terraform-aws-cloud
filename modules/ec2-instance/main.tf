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
