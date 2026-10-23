# VPC

Creates a VPC with IPv4 and IPv6, one public and one private subnet per availability zone, and a NAT Gateway in each zone. Includes S3 and DynamoDB gateway endpoints.

Requires Terraform `~> 1.2` and AWS provider `~> 6.0`.

## Usage

Set the AWS region, choose availability zones in that region, and assign a private `/16` that does not overlap your other networks.

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "andreygubarev/cloud/aws//modules/vpc"
  version = "~> 0.6.0"

  name = "main"

  network_availability_zones = ["us-east-1a", "us-east-1b"]
  network_cidr_ipv4          = "10.20.0.0/16"
}
```

This example creates two public and two private subnets, plus two NAT Gateways with Elastic IPs. **NAT gateways and public IPv4 addresses incur charges even without traffic.**

- Public subnets are `/22`; private subnets are `/20`.
- Private subnets reach the internet through the NAT Gateway in their own zone for IPv4, and an Egress-only Internet Gateway for IPv6. Neither path allows unsolicited inbound connections.
- For public subnets only, set `enable_private_subnets = false`. No NAT gateways are created unless NAT64 is enabled.
- To disable IPv6, set `network_cidr_ipv6 = false`.
- DNS64/NAT64 are off by default. If needed, set both `enable_dns64` and `enable_nat64` to `true`; IPv6 and public subnets must be enabled.

Use `module.vpc.network_vpc`, `module.vpc.network_public_subnets`, and `module.vpc.network_private_subnets` to connect other resources.
