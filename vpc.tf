resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name        = "tf_${var.name}_${var.region}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"
}
