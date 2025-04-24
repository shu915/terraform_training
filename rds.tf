resource "aws_db_parameter_group" "mysql_standalone_parameter_group" {
  name        = "${var.project}-${var.environment}-mysql-standalone-pg"
  family      = "mysql8.0"
  description = "${var.project}-${var.environment}-mysql-standalone-pg"
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "mysql_standalone_option_group" {
  name                 = "${var.project}-${var.environment}-mysql-standalone-og"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

resource "aws_db_subnet_group" "mysql_standalone_subnet_group" {
  name       = "${var.project}-${var.environment}-mysql-standalone-subnet-group"
  subnet_ids = [aws_subnet.private_subnet-1a.id, aws_subnet.private_subnet-1c.id]
}

resource "random_string" "db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql_standalone" {
  identifier     = "${var.project}-${var.environment}-mysql-standalone"
  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp2"
  storage_encrypted     = false

  multi_az          = false
  availability_zone = "ap-northeast-1a"

  username = "admin"
  password = random_string.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  port                   = 3306

  name                 = "testylog"
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name
  option_group_name    = aws_db_option_group.mysql_standalone_option_group.name

  backup_window              = "04:00-05:00"
  backup_retention_period    = 7
  maintenance_window         = "mon:05:00-mon:08:00"
  auto_minor_version_upgrade = false

  deletion_protection = true
  skip_final_snapshot = true
  apply_immediately = true

  tags = {
    Name        = "${var.project}-${var.environment}-mysql-standalone"
    Project     = var.project
    Environment = var.environment
  }
}