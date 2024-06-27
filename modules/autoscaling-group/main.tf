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
# Keypair
################################################################################

resource "tls_private_key" "this" {
  algorithm = var.instance_keypair_algoirthm
}

resource "aws_key_pair" "this" {
  key_name   = local.name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_secretsmanager_secret" "this" {
  name = "${local.name_unique}-keypair"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = tls_private_key.this.private_key_openssh
}

################################################################################
# Instance Profile
################################################################################

resource "aws_iam_role" "this" {
  name = local.name_unique
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = local.name_unique
  role = aws_iam_role.this.name
}

################################################################################
# Instance Profile's Policies
################################################################################

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.instance_profile_policies)

  policy_arn = each.key
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_readonly_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_policy" "complete_lifecycle_action" {
  name = "${local.name_unique}-lifecycle-action"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["autoscaling:CompleteLifecycleAction"]
        Effect   = "Allow"
        Resource = aws_autoscaling_group.this.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "complete_lifecycle_action" {
  policy_arn = aws_iam_policy.complete_lifecycle_action.arn
  role       = aws_iam_role.this.name
}

################################################################################
# Cloud-init
################################################################################

resource "aws_s3_bucket" "cloud_init" {
  bucket = "cloud-init-${local.name_unique}"
}

resource "aws_s3_bucket_ownership_controls" "cloud_init" {
  bucket = aws_s3_bucket.cloud_init.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloud_init" {
  depends_on = [aws_s3_bucket_ownership_controls.cloud_init]

  bucket = aws_s3_bucket.cloud_init.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "cloud_init" {
  bucket = aws_s3_bucket.cloud_init.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "cloud_init" {
  bucket = aws_s3_bucket.cloud_init.bucket
  key    = "bootstrap.run"

  source = var.instance_user_data
  etag    = md5(file(var.instance_user_data))

  depends_on = [
    var.instance_ami,
    var.instance_ami_owner
  ]
}

data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/cloud-init.sh.tftpl", {
      bootstrap_bucket  = aws_s3_bucket.cloud_init.bucket
      bootstrap_object  = aws_s3_object.cloud_init.id
      bootstrap_version = aws_s3_object.cloud_init.version_id
    })
    filename = "cloud-init.sh"
  }

  depends_on = [
    var.instance_ami,
    var.instance_ami_owner
  ]
}

resource "aws_iam_policy" "cloud_init" {
  name = "${local.name_unique}-cloud-init"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.cloud_init.arn}/*",
          aws_s3_bucket.cloud_init.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_init" {
  policy_arn = aws_iam_policy.cloud_init.arn
  role       = aws_iam_role.this.name
}

################################################################################
# Launch Template
################################################################################

resource "aws_launch_template" "this" {
  name = local.name

  instance_type                        = data.aws_ec2_instance_type.this.instance_type
  image_id                             = data.aws_ami.this.id
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = aws_key_pair.this.key_name
  user_data                            = data.cloudinit_config.this.rendered

  vpc_security_group_ids = data.aws_security_groups.this.ids

  iam_instance_profile { arn = aws_iam_instance_profile.this.arn }
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

    tags = local.tags
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

resource "aws_autoscaling_lifecycle_hook" "this" {
  name = "cloud-init"

  autoscaling_group_name = aws_autoscaling_group.this.name
  default_result         = "ABANDON"
  heartbeat_timeout      = var.group_timeout_heartbeat
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "aws_autoscaling_notification" "this" {
  count = var.group_notification_topic != "" ? 1 : 0

  group_names = [
    aws_autoscaling_group.this.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.group_notification_topic
}
