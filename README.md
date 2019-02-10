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

TODO

## Suggested Additions

It is generally recommended to use a bastion instance to
restrict SSH access to your instances. You will be forced
to attach it to the create node and master security groups
(available through module outputs).
