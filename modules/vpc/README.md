# `andreygubarev/cloud/aws//vpc`

Terraform module to create a VPC with public and private subnets across multiple availability zones. Module creates the following resources:
- AWS VPC with IPv6 support
- Public subnets with Internet Gateway
- Private subnets with NAT Gateway with Elastic IP
- Default Security Group

Network CIDR block is divided into subnets with the following rules:
- Public subnets have *1024* addresses and created in the first part of the CIDR block (`x.x.0.0` - `x.x.31.255`)
- Private subnets have *4096* addresses and created in the second half of the CIDR block (`x.x.32.0` - `x.x.175.255`)
- Every availability zone has one public and one private subnet

## Quick start

```hcl
module "vpc" {
  source  = "andreygubarev/vpc/aws"

  name = "vpc"

  network_region = "us-east-1"
  network_availability_zones = [
    "us-east-1f",
  ]
  network_cidr = "172.17.0.0/16"
}
```
