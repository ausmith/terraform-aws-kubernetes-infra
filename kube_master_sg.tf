resource "aws_security_group" "kube_master_sg" {
  vpc_id      = "${aws_vpc.default.id}"
  name        = "kube_master_sg_${var.name}"
  description = "kube ${var.name} master SG"

  tags {
    Name        = "kube_master_sg_${var.name}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

output "kube_master_sg" {
  value = "${aws_security_group.kube_master_sg.id}"
}

resource "aws_security_group_rule" "kube_master_human_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Human HTTPS"

  cidr_blocks = [
    "${var.control_origins}",
  ]

  security_group_id = "${aws_security_group.kube_master_sg.id}"
}

resource "aws_security_group_rule" "kube_master_from_node_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "Allow ingress from kube nodes for HTTPS"
}

resource "aws_security_group_rule" "kube_master_from_masters_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "kube node HTTPS"
}

resource "aws_security_group_rule" "kube_master_etcd_private_ingress" {
  type                     = "ingress"
  from_port                = 2380
  to_port                  = 2381
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master etcd 2380-2381"
}

resource "aws_security_group_rule" "kube_master_etcd_manager_ingress" {
  type                     = "ingress"
  from_port                = 3994
  to_port                  = 3997
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master etcd 3994-3997"
}

resource "aws_security_group_rule" "kube_master_kubelet_ingress" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master kubelet 10250"
}

resource "aws_security_group_rule" "kube_master_from_master_cni_tcp_ports" {
  count                    = "${length(var.cni_tcp_ports)}"
  type                     = "ingress"
  from_port                = "${element(var.cni_tcp_ports, count.index)}"
  to_port                  = "${element(var.cni_tcp_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master cni tcp port ${element(var.cni_tcp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_from_node_cni_tcp_ports" {
  count                    = "${length(var.cni_tcp_ports)}"
  type                     = "ingress"
  from_port                = "${element(var.cni_tcp_ports, count.index)}"
  to_port                  = "${element(var.cni_tcp_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "node-master cni tcp port ${element(var.cni_tcp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_from_master_cni_udp_ports" {
  count                    = "${length(var.cni_udp_ports)}"
  type                     = "ingress"
  from_port                = "${element(var.cni_udp_ports, count.index)}"
  to_port                  = "${element(var.cni_udp_ports, count.index)}"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master cni udp port ${element(var.cni_udp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_from_node_cni_udp_ports" {
  count                    = "${length(var.cni_udp_ports)}"
  type                     = "ingress"
  from_port                = "${element(var.cni_udp_ports, count.index)}"
  to_port                  = "${element(var.cni_udp_ports, count.index)}"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "node-master cni udp port ${element(var.cni_udp_ports, count.index)}"
}

resource "aws_security_group_rule" "master_master_etcd_private_egress" {
  type                     = "egress"
  from_port                = 2380
  to_port                  = 2381
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master etcd 2380-2381"
}

resource "aws_security_group_rule" "kube_master_etcd_manager_egress" {
  type                     = "egress"
  from_port                = 3994
  to_port                  = 3997
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master etcd 3994-3997"
}

resource "aws_security_group_rule" "kube_master_to_masters" {
  # TODO: make explicit rules for etcd access, etc, instead of this wide rule
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master all cause lazy"
}

resource "aws_security_group_rule" "kube_master_to_node_all" {
  # TODO: needs to be tightened down!
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-node all cause lazy"
}

/*
# TODO: unsure if required anymore
resource "aws_security_group_rule" "kube_master_to_localhost_and_kube" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = "${aws_security_group.kube_master_sg.id}"
  description       = "localhost-master all cause lazy"

  # TODO: 127.0.0.0/8 gives localhost, deprecate?
  # TODO: 100.64.0.0/10 gives kubenet CIDR access, vxlan replaces?
  cidr_blocks = [
    "127.0.0.0/8",
    "100.64.0.0/10",
  ]
}
*/

resource "aws_security_group_rule" "kube_master_https_to_internet" {
  # Alas, without this we cannot fetch docker containers
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "HTTPS to the internet"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  security_group_id = "${aws_security_group.kube_master_sg.id}"
}

resource "aws_security_group_rule" "kube_master_master_kubelet_egress" {
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master kubelet 10250"
}

resource "aws_security_group_rule" "kube_master_node_kubelet_egress" {
  type                     = "egress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "node-master kubelet 10250"
}

resource "aws_security_group_rule" "kube_master_to_master_cni_tcp_ports" {
  count                    = "${length(var.cni_tcp_ports)}"
  type                     = "egress"
  from_port                = "${element(var.cni_tcp_ports, count.index)}"
  to_port                  = "${element(var.cni_tcp_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master cni tcp port ${element(var.cni_tcp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_to_node_cni_tcp_ports" {
  count                    = "${length(var.cni_tcp_ports)}"
  type                     = "egress"
  from_port                = "${element(var.cni_tcp_ports, count.index)}"
  to_port                  = "${element(var.cni_tcp_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-node cni tcp port ${element(var.cni_tcp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_to_master_cni_udp_ports" {
  count                    = "${length(var.cni_udp_ports)}"
  type                     = "egress"
  from_port                = "${element(var.cni_udp_ports, count.index)}"
  to_port                  = "${element(var.cni_udp_ports, count.index)}"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_master_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-master cni udp port ${element(var.cni_udp_ports, count.index)}"
}

resource "aws_security_group_rule" "kube_master_to_node_cni_udp_ports" {
  count                    = "${length(var.cni_udp_ports)}"
  type                     = "egress"
  from_port                = "${element(var.cni_udp_ports, count.index)}"
  to_port                  = "${element(var.cni_udp_ports, count.index)}"
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.kube_node_sg.id}"
  security_group_id        = "${aws_security_group.kube_master_sg.id}"
  description              = "master-node cni udp port ${element(var.cni_udp_ports, count.index)}"
}
