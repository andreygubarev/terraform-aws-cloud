data "aws_region" "this" {}

data "aws_availability_zones" "this" {
  filter {
    name   = "region-name"
    values = [data.aws_region.this.name]
  }

  filter {
    name   = "zone-name"
    values = local.network_availability_zones
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [data.aws_region.this.name]
  }
}

locals {
  availability_zones = {
    for az in data.aws_availability_zones.this.names :
    az => "${split("-", az)[0]}${substr(split("-", az)[1], 0, 1)}${split("-", az)[2]}"
  }
}

data "aws_security_group" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }

  filter {
    name   = "group-name"
    values = ["default"]
  }
}
