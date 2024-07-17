################################################################################
# AWS EC2 Launch Template
################################################################################

resource "aws_launch_template" "this" {
  name = var.name

  image_id      = data.aws_ami.this.id
  instance_type = data.aws_ec2_instance_type.this.instance_type

  instance_initiated_shutdown_behavior = "terminate"

  ebs_optimized = true
  block_device_mappings {
    device_name = data.aws_ami.this.root_device_name

    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  disable_api_stop        = false
  disable_api_termination = false

  key_name = var.instance_keypair
  iam_instance_profile {
    name = var.instance_profile
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = var.network_security_groups

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = var.tags
  }

  user_data = base64encode(var.instance_userdata)
}
