# `andreygubarev/cloud/aws//vpc`

Terraform module to create a VPC with public and private subnets across multiple availability zones. Module creates the following resources:
- AWS VPC with IPv6 support
- Public subnets with Internet Gateway
- Private subnets with NAT Gateway

Network CIDR block is divided into subnets with the following rules:
- Public subnets have *1024* addresses and created in the first part of the CIDR block (`x.x.0.0` - `x.x.31.255`)
- Private subnets have *4096* addresses and created in the second half of the CIDR block (`x.x.32.0` - `x.x.175.255`)
- Every availability zone has one public and one private subnet

## Quick start

```hcl
module "vpc" {
  source  = "andreygubarev/cloud/aws//modules/vps"

  name = "vpc"

  network_availability_zones = ["us-east-1f"]
  network_cidr_ipv4 = "172.20.0.0/16"
  network_cidr_ipv6 = true

  enable_public_subnets = true
  enable_private_subnets = false
  enable_public_ipv4 = true
  enable_public_ipv6 = true
}
```


Notes:

DNS64 and NAT64 requires NAT Gateway in public subnet, NAT Gateway requires Internet Gateway.

https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html#nat-gateway-nat64-dns64-walkthrough
