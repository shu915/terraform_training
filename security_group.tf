resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.environment}-sg-web"
  description = "${var.project}-${var.environment}-sg-web"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-web"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "web_sg_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_sg_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_sg_out_tcp_3000" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.environment}-sg-app"
  description = "${var.project}-${var.environment}-sg-app"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-app"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "app_sg_in_tcp_3000" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "app_sg_out_http_80" {
  security_group_id = aws_security_group.app_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3_prefix_list.id]
}

resource "aws_security_group_rule" "app_sg_out_https_443" {
  security_group_id = aws_security_group.app_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3_prefix_list.id]
}

resource "aws_security_group_rule" "app_out_tcp_3306" {
  security_group_id        = aws_security_group.app_sg.id
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group" "opnmg_sg" {
  name        = "${var.project}-${var.environment}-sg-opnmg"
  description = "Operation and manegement role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-opnmg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "opnmg_in_ssh" {
  security_group_id = aws_security_group.opnmg_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opnmg_in_tcp_3000" {
  security_group_id = aws_security_group.opnmg_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opnmg_out_http" {
  security_group_id = aws_security_group.opnmg_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "opnmg_out_https" {
  security_group_id = aws_security_group.opnmg_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.environment}-sg-db"
  description = "${var.project}-${var.environment}-sg-db"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-db"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "db_in_tcp_3306" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
}