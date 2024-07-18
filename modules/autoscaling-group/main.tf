################################################################################
# Auto Scaling Group
################################################################################

resource "aws_autoscaling_group" "this" {
  name = var.name

  min_size              = var.group_capacity_min
  max_size              = var.group_capacity_max
  desired_capacity      = var.group_capacity_min
  protect_from_scale_in = false

  default_cooldown          = var.group_timeout_cooldown
  health_check_grace_period = var.group_timeout_grace_period
  health_check_type         = "EC2"

  launch_template {
    id      = var.instance_launch_template.id
    version = var.instance_launch_template.version
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
    for_each = var.tags
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
