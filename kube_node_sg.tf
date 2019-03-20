resource "aws_security_group" "kube_node_sg" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "kube_node_sg_${var.name}"
  description = "kube ${var.name} node SG"

  tags {
    Name        = "kube_node_sg_${var.name}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

output "kube_node_sg" {
  value = "${aws_security_group.kube_node_sg.id}"
}

resource "aws_security_group_rule" "kube_ingress_rules" {
  count             = "${length(var.ingress_ports)}"
  type              = "ingress"
  from_port         = "${element(var.ingress_ports, count.index)}"
  to_port           = "${element(var.ingress_ports, count.index)}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kube_node_sg.id}"
  description       = "external-node ingress ${element(var.ingress_ports, count.index)}"

  cidr_blocks = [
    "0.0.0.0/0",
    "${var.vpc_cidr}",
  ]
}

resource "aws_security_group_rule" "kube_node_from_master_vxlan_canal_ingress" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  description              = "master-node vxlan 8472"
}

resource "aws_security_group_rule" "kube_node_from_node_vxlan_canal_ingress" {
  type                     = "ingress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  description              = "node-node vxlan 8472"
}

resource "aws_security_group_rule" "kube_master_node_kubelet_ingress" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  description              = "master-node kubelet 10250"
}

/*
# TODO: unsure if required any longer
resource "aws_security_group_rule" "kube_node_to_localhost_and_kube" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = "${aws_security_group.kube_node_sg.id}"
  description       = "localhost-node all cause lazy"

  # TODO: 127.0.0.0/8 gives localhost, deprecate?
  # TODO: 100.64.0.0/10 gives kubenet CIDR access, vxlan replaces?
  cidr_blocks = [
    "127.0.0.0/8",
    "100.64.0.0/10",
  ]
}
*/

resource "aws_security_group_rule" "kube_nodes_to_masters_https_egress" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  description              = "node-master API 443"
}

resource "aws_security_group_rule" "kube_nodes_https_to_internet" {
  # Alas, without this we cannot fetch docker containers
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "HTTPS to the internet"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = "${aws_security_group.kube_node_sg.id}"
}

resource "aws_security_group_rule" "kube_node_to_master_vxlan_canal_egress" {
  type                     = "egress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  description              = "node-master vxlan 8472"
}

resource "aws_security_group_rule" "kube_node_to_node_vxlan_canal_egress" {
  type                     = "egress"
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_node_sg.id}"
  description              = "node-node vxlan 8472"
}
