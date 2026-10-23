data "aws_region" "this" {}

data "aws_availability_zones" "this" {
  filter {
    name   = "region-name"
    values = [data.aws_region.this.region]
  }

  filter {
    name   = "zone-name"
    values = local.network_availability_zones
  }

  lifecycle {
    postcondition {
      condition     = toset(self.names) == toset(var.network_availability_zones)
      error_message = "network_availability_zones must contain only availability zones accessible in the current AWS region"
    }

    postcondition {
      condition = alltrue([
        for az in self.names : try(index(data.aws_availability_zones.available.names, az) < 8, false)
      ])
      error_message = "network_availability_zones must use zones with indices 0-7 in the region's availability zone list to avoid overlapping subnet CIDRs"
    }
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [data.aws_region.this.region]
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
