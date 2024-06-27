################################################################################
# Name
################################################################################

resource "random_string" "this" {
  length = 4

  # only upper case letters
  special = false
  upper   = false
  lower   = true
  numeric = false
}

locals {
  name        = var.name
  name_unique = "${var.name}-${random_string.this.result}"
  tags        = var.tags
}

################################################################################
# Launch Template
################################################################################

resource "aws_launch_template" "this" {
  name = local.name

  instance_type                        = data.aws_ec2_instance_type.this.instance_type
  image_id                             = data.aws_ami.this.id
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = data.aws_key_pair.this.key_name
  user_data                            = var.instance_userdata

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "resource-name"
  }

  vpc_security_group_ids = data.aws_security_groups.this.ids

  iam_instance_profile { name = var.instance_profile }
  credit_specification { cpu_credits = "standard" }
  monitoring { enabled = true }

  ebs_optimized = true
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }
}

################################################################################
# Auto Scaling Group
################################################################################

resource "aws_autoscaling_group" "this" {
  name = local.name

  min_size              = var.group_capacity_min
  max_size              = var.group_capacity_max
  desired_capacity      = var.group_capacity_min
  protect_from_scale_in = false

  default_cooldown          = var.group_timeout_cooldown
  health_check_grace_period = var.group_timeout_grace_period
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  vpc_zone_identifier = data.aws_subnets.this.ids

  termination_policies = ["OldestInstance"]
  dynamic "instance_refresh" {
    for_each = var.group_instance_refresh ? [true] : []
    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 0
      }
    }
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
      target_group_arns,
    ]
  }
}
