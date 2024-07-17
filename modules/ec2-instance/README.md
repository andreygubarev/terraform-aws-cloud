# `andreygubarev/cloud/aws//ec2-instance`

Terraform module to create an EC2 instance in AWS.

## Usage

```hcl
module "instance" {
  source  = "andreygubarev/cloud/aws//modules/ec2-instance"
  version = "~> 0.4"

  name = var.name

  network_vpc             = var.network_vpc
  network_subnet          = var.network_subnet
  network_security_groups = var.network_security_groups

  instance_type    = var.instance_type
  instance_ami     = var.instance_ami
  instance_keypair = var.instance_keypair
  instance_profile = var.instance_profile

  volume_type = "gp3" # optional
  volume_size = 8     # optional

  volume_devices = {  # optional
    "/dev/xvdb1" = {
      volume_type = "gp3"
      volume_size = 8
    }
  }
}
```
