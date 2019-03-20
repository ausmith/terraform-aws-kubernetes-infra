# terraform-aws-kubernetes-infra

A Terraform module for basic infrastructure in AWS required
to setup a Kubernetes cluster. This is very opinionated!
Please consider the resources being created and consider
modifying the resulting resources if you disagree with the
design decisions.

## NOTE: CURRENTLY UNTESTED MODULE

## Included Resources

* VPC
* Subnet
* Basic Route Table
* NAT Gateway
* [optional] Node NLB
* Master Security Group
* Node Security Group
* S3 Endpoint

## Usage Example

```
module "kubeinfra" {
  source = "github.com/ausmith/terraform-aws-kubernetes-infra"

  vpc_cidr           = "${var.vpc_cidr}"
  name               = "prototype"
  region             = "us-west-2"
  owner_tag          = "me"
  env_tag            = "prod"
  toggle_ingress_nlb = 0

  # This is ugly enumerating out each AZ, templating perhaps?
  az_list = [
    "us-west-2a",
    "us-west-2b",
  ]

  # Will need to template these CIDRs somehow
  public_subnet_cidrs = [
    "172.20.0.0/24",
    "172.20.1.0/24",
  ]

  private_subnet_cidrs = [
    "172.20.10.0/24",
    "172.20.11.0/24",
  ]

  ingress_ports = []

  control_origins = [
    "${var.my_public_ip_cidr}",
  ]
}
```

## Suggested Additions

It is generally recommended to use a bastion instance to
restrict SSH access to your instances. You will be forced
to attach it to the create node and master security groups
(available through module outputs).
