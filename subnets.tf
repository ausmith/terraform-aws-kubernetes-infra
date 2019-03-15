resource "aws_subnet" "public" {
  count  = "${length(var.az_list)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block              = "${element(var.public_subnet_cidrs, count.index)}"
  availability_zone       = "${element(var.az_list, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public ${var.name} ${element(var.az_list, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
    ZoneType    = "public"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.az_list)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

output "public_subnet_list" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

######################################

resource "aws_subnet" "private" {
  count  = "${length(var.az_list)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${element(var.private_subnet_cidrs, count.index)}"
  availability_zone = "${element(var.az_list, count.index)}"

  tags = {
    Name        = "Private ${var.name} ${element(var.az_list, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
    ZoneType    = "private"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.az_list)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}

output "private_subnet_list" {
  value = "${join(",", aws_subnet.private.*.id)}"
}
