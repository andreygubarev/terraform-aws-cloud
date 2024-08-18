###############################################################################
# AWS
###############################################################################

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

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

data "aws_subnet" "this" {
  vpc_id = data.aws_vpc.this.id

  filter {
    name   = "subnet-id"
    values = var.network_subnets
  }
}
