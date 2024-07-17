# `andreygubarev/cloud/aws//ec2-instance`

Terraform module to create an EC2 instance in AWS.

## Usage

```hcl
module "ec2_instance" {
  source  = "andreygubarev/cloud/aws//modules/ec2-instance"
  version = ""

  name = var.name

  network_subnet          = var.network_subnet
  network_security_groups = var.network_security_groups

  instance_type      = var.instance_type
  instance_ami       = var.instance_ami
  instance_ami_owner = var.instance_ami_owner

  instance_keypair        = var.instance_keypair
  instance_profile        = var.instance_profile
  instance_cloudinit      = file("${path.module}/files/cloud-config.yml")
  instance_cloudinit_type = "text/cloud-config"
}
```
