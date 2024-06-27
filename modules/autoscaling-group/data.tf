################################################################################
# Location
################################################################################

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

################################################################################
# Network
################################################################################

data "aws_vpc" "this" {
  id = var.network_vpc
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "subnet-id"
    values = var.network_subnets
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
  filter {
    name   = "image-id"
    values = [var.instance_ami]
  }
  most_recent = true
  owners      = [var.instance_ami_owner]
}
