################################################################################
# Network
################################################################################

data "aws_vpc" "this" {
  state = "available"

  filter {
    name   = "vpc-id"
    values = [var.network_vpc]
  }
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
