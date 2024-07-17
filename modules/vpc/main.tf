locals {
  enable_ipv4 = true # TODO: add support for IPv6 only VPC
  enable_ipv6 = var.network_cidr_ipv6

  enable_public_subnets  = var.enable_public_subnets
  enable_private_subnets = var.enable_private_subnets
  enable_subnets         = local.enable_public_subnets && local.enable_private_subnets

  enable_public_ipv4 = local.enable_ipv4 && var.enable_public_ipv4
  enable_public_ipv6 = local.enable_ipv6 && var.enable_public_ipv6

  enable_dns64 = (local.enable_ipv4 == false) && (local.enable_ipv6 == true)
  enable_nat64 = local.enable_dns64 && local.enable_private_subnets
}

################################################################################
# AWS VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block                       = var.network_cidr_ipv4
  assign_generated_ipv6_cidr_block = var.network_cidr_ipv6

  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true

  tags = {
    Name = var.name
  }
}

################################################################################
# AWS VPC | DHCP Options
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  ntp_servers         = ["169.254.169.123"]

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id

  depends_on = [
    aws_vpc.this,
  ]
}

################################################################################
# AWS VPC Subnets
################################################################################

locals {
  # ipv4 public ~ x.x.0.0 - x.x.31.255 (8 subnets, 1024 IPs each)
  public_ipv4_netmask = 6 # 16 + 6 = 22 ~ 1024 IPs
  public_ipv4_netnum  = 0 # start at 0

  # ipv4 private ~ x.x.32.0 - x.x.175.255 (8 subnets, 4096 IPs each)
  private_ipv4_netmask = 4 # 16 + 4 = 20 ~ 4096 IPs
  private_ipv4_netnum  = 2 # start at 2 to avoid conflicting with the public subnets

  # ipv6 public ~ auto-assigned
  public_ipv6_netmask = 8
  public_ipv6_netnum  = 0

  # ipv6 private ~ auto-assigned
  private_ipv6_netmask = 8
  private_ipv6_netnum  = 8
}

################################################################################
# AWS VPC Subnets | Public
################################################################################

resource "aws_subnet" "public" {
  for_each = local.enable_public_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key

  # ipv4 public
  enable_resource_name_dns_a_record_on_launch = local.enable_ipv4
  map_public_ip_on_launch                     = local.enable_public_ipv4
  cidr_block = local.enable_ipv4 ? cidrsubnet(
    aws_vpc.this.cidr_block,
    local.public_ipv4_netmask,
    local.public_ipv4_netnum + index(data.aws_availability_zones.available.names, each.key)
  ) : null

  # ipv6 public
  enable_resource_name_dns_aaaa_record_on_launch = local.enable_ipv6
  assign_ipv6_address_on_creation                = local.enable_public_ipv6
  ipv6_cidr_block = local.enable_ipv6 ? cidrsubnet(
    aws_vpc.this.ipv6_cidr_block,
    local.public_ipv6_netmask,
    local.public_ipv6_netnum + index(data.aws_availability_zones.available.names, each.key)
  ) : null

  enable_dns64 = local.enable_dns64 # TODO: add support for IPv6 only VPC

  tags = {
    "Name" = "${var.name}-public-${local.availability_zones[each.key]}"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "public" {
  for_each = local.enable_public_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}-public-${local.availability_zones[each.key]}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.enable_public_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id = aws_route_table.public[each.key].id
  subnet_id      = aws_subnet.public[each.key].id
}

resource "aws_internet_gateway" "public" {
  count = local.enable_public_subnets ? 1 : 0

  tags = {
    "Name" = "${var.name}"
  }

  depends_on = [
    aws_route_table_association.public,
  ]
}

resource "aws_internet_gateway_attachment" "public" {
  count = local.enable_public_subnets ? 1 : 0

  internet_gateway_id = aws_internet_gateway.public[0].id
  vpc_id              = aws_vpc.this.id
}

resource "aws_route" "public_internet_gateway_ipv4" {
  for_each = local.enable_public_subnets && local.enable_ipv4 ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public[0].id

  depends_on = [
    aws_route_table_association.public,
  ]
}

resource "aws_route" "public_internet_gateway_ipv6" {
  for_each = local.enable_public_subnets && local.enable_ipv6 ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id              = aws_route_table.public[each.key].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.public[0].id

  depends_on = [
    aws_route_table_association.public,
  ]
}

################################################################################
# AWS VPC Subnets | NAT Gateway and Egress Only Internet Gateway
################################################################################

resource "aws_eip" "this" {
  for_each = local.enable_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  domain = "vpc"

  tags = {
    "Name" = "${var.name}-${local.availability_zones[each.key]}"
  }
  depends_on = [
    aws_vpc.this,
    aws_internet_gateway.public,
  ]
}

resource "aws_nat_gateway" "this" {
  for_each = local.enable_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    "Name" = "${var.name}-${local.availability_zones[each.key]}"
  }

  depends_on = [
    aws_internet_gateway.public,
    aws_route.public_internet_gateway_ipv4,
    aws_route.public_internet_gateway_ipv6,
  ]
}

resource "aws_egress_only_internet_gateway" "this" {
  count = local.enable_private_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}"
  }
}
################################################################################
# AWS VPC Subnets | Private
################################################################################

resource "aws_subnet" "private" {
  for_each = local.enable_private_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key

  # ipv4 private
  enable_resource_name_dns_a_record_on_launch = local.enable_ipv4
  map_public_ip_on_launch                     = false
  cidr_block = local.enable_ipv4 ? cidrsubnet(
    aws_vpc.this.cidr_block,
    local.private_ipv4_netmask,
    local.private_ipv4_netnum + index(data.aws_availability_zones.available.names, each.key)
  ) : null

  # ipv6 private
  enable_resource_name_dns_aaaa_record_on_launch = local.enable_ipv6
  assign_ipv6_address_on_creation                = local.enable_public_ipv6
  ipv6_cidr_block = local.enable_ipv6 ? cidrsubnet(
    aws_vpc.this.ipv6_cidr_block,
    local.private_ipv6_netmask,
    local.private_ipv6_netnum + index(data.aws_availability_zones.available.names, each.key)
  ) : null

  tags = {
    "Name" = "${var.name}-private-${local.availability_zones[each.key]}"

    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "private" {
  for_each = local.enable_private_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}-private-${local.availability_zones[each.key]}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.enable_private_subnets ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}

resource "aws_route" "private_egress_ipv4" {
  for_each = local.enable_subnets && local.enable_ipv4 ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route" "private_egress_ipv6" {
  for_each = local.enable_private_subnets && local.enable_ipv6 ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id              = aws_route_table.private[each.key].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this[0].id
}

resource "aws_route" "private_nat64" {
  for_each = local.enable_nat64 ? toset(data.aws_availability_zones.this.names) : toset([])

  route_table_id              = aws_route_table.private[each.key].id
  destination_ipv6_cidr_block = "64:ff9b::/96"
  nat_gateway_id              = aws_nat_gateway.this[each.key].id
}

################################################################################
# AWS VPC Endpoints
################################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${data.aws_region.this.name}.s3"
  route_table_ids = concat(
    [for rt in aws_route_table.public : rt.id],
    [for rt in aws_route_table.private : rt.id],
  )

  tags = {
    "Name" = "${var.name}-vpce-s3"
  }

  depends_on = [
    aws_vpc.this,
    aws_route_table.public,
    aws_route_table.private,
  ]
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${data.aws_region.this.name}.dynamodb"
  route_table_ids = concat(
    [for rt in aws_route_table.public : rt.id],
    [for rt in aws_route_table.private : rt.id],
  )

  tags = {
    "Name" = "${var.name}-vpce-dynamodb"
  }

  depends_on = [
    aws_vpc.this,
    aws_route_table.public,
    aws_route_table.private,
  ]
}
