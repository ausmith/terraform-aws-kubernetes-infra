resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(
		map("Name", "tf_${var.name}_${var.region}"),
		map("Owner", "${var.owner_tag}"),
		map("Environment", "${var.env_tag}"),
		map("kubernetes.io/cluster/${var.name}", "shared"),
	)}"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"
}
