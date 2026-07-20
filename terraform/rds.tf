# --- MC-06: publicly accessible RDS instance -------------------------------
resource "aws_db_subnet_group" "cloudguardian" {
  name       = "cloudguardian-db-subnet-group"
  subnet_ids = data.aws_subnets.cloudguardian.ids
  tags       = { Project = "CloudGuardian" }
}

resource "aws_db_instance" "cloudguardian" {
  identifier     = "cloudguardian-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "cloudguardian"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.cloudguardian.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Misconfigured: instance is reachable from the public internet.
  # Remediated: private-only, reachable through the web tier / VPN only.
  publicly_accessible = var.enable_misconfigurations ? true : false

  skip_final_snapshot = true
  apply_immediately   = true

  tags = { Project = "CloudGuardian", Finding = "MC-06" }
}
