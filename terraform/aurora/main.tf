provider "aws" {
  region = "us-west-2"
}

# Generate random password if not provided
resource "random_password" "master_password" {
  count   = var.master_password == null ? 1 : 0
  length  = 16
  special = true
}

locals {
  master_password = var.master_password != null ? var.master_password : random_password.master_password[0].result
  
  common_tags = merge(var.tags, {
    Name        = var.cluster_identifier
    Environment = var.environment
    Service     = "helicone"
    ManagedBy   = "terraform"
  })
}

# Security Group for Aurora PostgreSQL
resource "aws_security_group" "aurora_sg" {
  name_prefix = "${var.cluster_identifier}-aurora-"
  vpc_id      = var.vpc_id

  description = "Security group for Aurora PostgreSQL cluster"

  # PostgreSQL port
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    cidr_blocks     = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_identifier}-aurora-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  description = "DB subnet group for Aurora PostgreSQL cluster"

  tags = merge(local.common_tags, {
    Name = "${var.cluster_identifier}-subnet-group"
  })
}

# DB Parameter Group for Aurora PostgreSQL
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  family      = "aurora-postgresql15"
  name        = "${var.cluster_identifier}-cluster-params"
  description = "Aurora PostgreSQL cluster parameter group"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# DB Parameter Group for Aurora PostgreSQL instances
resource "aws_db_parameter_group" "aurora_instance_parameter_group" {
  family = "aurora-postgresql15"
  name   = "${var.cluster_identifier}-instance-params"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Enhanced Monitoring Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.enable_monitoring ? 1 : 0
  name  = "${var.cluster_identifier}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.enable_monitoring ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier              = var.cluster_identifier
  engine                         = "aurora-postgresql"
  engine_version                 = var.engine_version
  database_name                  = var.database_name
  master_username                = var.master_username
  master_password                = local.master_password
  backup_retention_period        = var.backup_retention_period
  preferred_backup_window        = var.preferred_backup_window
  preferred_maintenance_window   = var.preferred_maintenance_window
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.name
  db_subnet_group_name           = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids         = [aws_security_group.aurora_sg.id]
  
  storage_encrypted               = true
  kms_key_id                     = aws_kms_key.aurora_kms_key.arn
  
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = local.common_tags

  depends_on = [
    aws_rds_cluster_parameter_group.aurora_cluster_parameter_group,
    aws_db_subnet_group.aurora_subnet_group
  ]

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      master_password
    ]
  }
}

# Aurora PostgreSQL Cluster Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version
  
  db_parameter_group_name = aws_db_parameter_group.aurora_instance_parameter_group.name
  
  monitoring_interval = var.enable_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn = var.enable_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  tags = merge(local.common_tags, {
    Name = "${var.cluster_identifier}-instance-${count.index + 1}"
  })

  depends_on = [
    aws_rds_cluster.aurora_cluster,
    aws_db_parameter_group.aurora_instance_parameter_group
  ]
}

# KMS Key for Aurora encryption
resource "aws_kms_key" "aurora_kms_key" {
  description             = "KMS key for Aurora PostgreSQL cluster encryption"
  deletion_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${var.cluster_identifier}-kms-key"
  })
}

resource "aws_kms_alias" "aurora_kms_alias" {
  name          = "alias/${var.cluster_identifier}-aurora-key"
  target_key_id = aws_kms_key.aurora_kms_key.key_id
}

# Store master password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "aurora_master_password" {
  name        = "${var.cluster_identifier}-master-password"
  description = "Master password for Aurora PostgreSQL cluster"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "aurora_master_password" {
  secret_id = aws_secretsmanager_secret.aurora_master_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = local.master_password
    endpoint = aws_rds_cluster.aurora_cluster.endpoint
    port     = aws_rds_cluster.aurora_cluster.port
    dbname   = var.database_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
} 