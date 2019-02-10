resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = "${aws_vpc.default.id}"
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3_association" {
  vpc_endpoint_id = "${aws_vpc_endpoint.private_s3.id}"
  route_table_id  = "${aws_route_table.public_route_table.id}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3_association" {
  count           = "${length(var.az_list)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.private_s3.id}"
  route_table_id  = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}
