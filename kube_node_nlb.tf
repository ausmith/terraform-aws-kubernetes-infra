resource "aws_lb_target_group" "ingress_tgs" {
  count    = "${length(var.ingress_ports)}"
  name     = "kube-nodes-${element(var.ingress_ports, count.index)}-${aws_vpc.default.id}"
  port     = "${element(var.ingress_ports, count.index)}"
  protocol = "TCP"
  vpc_id   = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.name}-${element(var.ingress_ports, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }

  /*
# TODO: Enable health checking with some form of toggling
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = 8999
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }
*/
}

output "ingress_tg_list" {
  value = "${aws_lb_target_group.ingress_tgs.*.arn}"
}

#################################################

# General External NLB:
resource "aws_lb" "ingress_nlb" {
  count                      = "${var.toggle_ingress_nlb}"
  name                       = "ingress-nlb-${var.name}"
  internal                   = false
  load_balancer_type         = "network"
  enable_deletion_protection = true

  subnets = [
    "${aws_subnet.public.*.id}",
  ]

  tags {
    Name        = "${var.name}-${element(var.ingress_ports, count.index)}"
    Owner       = "${var.owner_tag}"
    Environment = "${var.env_tag}"
  }
}

output "ingress_nlb_dns" {
  value = "${aws_lb.ingress_nlb.dns_name}"
}

resource "aws_lb_listener" "ingress_listener" {
  count             = "${length(var.az_list)}"
  load_balancer_arn = "${aws_lb.ingress_nlb.arn}"
  port              = "${element(var.ingress_ports, count.index)}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${element(aws_lb_target_group.ingress_tgs.*.arn, count.index)}"
    type             = "forward"
  }
}
