resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "Public Route Table"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

resource "aws_route_table" "private_route_table" {
  count  = "${length(var.az_list)}"
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.ha_nat_gw.*.id, count.index)}"
  }

  tags {
    Name        = "Private Route Table ${element(var.az_list, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

resource "aws_eip" "natgw_eip" {
  count = "${length(var.az_list)}"
  vpc   = true
}

resource "aws_nat_gateway" "ha_nat_gw" {
  count         = "${list(var.az_list)}"
  allocation_id = "${element(aws_eip.natgw_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name        = "nat-${element(var.az_list, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}
