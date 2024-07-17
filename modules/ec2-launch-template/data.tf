###############################################################################
# Network
###############################################################################

data "aws_vpc" "this" {
  state = "available"

  filter {
    name   = "vpc-id"
    values = [var.network_vpc]
  }
}

data "aws_security_groups" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "group-id"
    values = var.network_security_groups
  }
}

################################################################################
# Instance
################################################################################

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

data "aws_ami" "this" {
  most_recent = true

  dynamic "filter" {
    for_each = var.instance_ami
    content {
      name   = filter.key
      values = [filter.value]
    }
  }
}

data "aws_key_pair" "this" {
  key_name = var.instance_keypair
}

data "aws_iam_instance_profile" "this" {
  name = var.instance_profile
}
