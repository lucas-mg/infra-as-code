provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]  # Replace with your subnet IDs
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora"
  engine_version          = "5.7.12"
  availability_zones      = ["us-east-1a", "us-east-1b"]  # Replace with your desired availability zones
  database_name           = "<CHANGE>"
  master_username         = "<CHANGE>"
  master_password         = "<CHANGE>"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_db_instance" "aurora_instance" {
  identifier            = "aurora-instance"
  cluster_identifier    = aws_rds_cluster.aurora_cluster.id
  instance_class        = "db.t2.small"  # Replace with your desired instance type
  engine                = "aurora"
  engine_version        = "5.7.12"
  publicly_accessible  = false
  db_subnet_group_name  = aws_db_subnet_group.aurora_subnet_group.name
}

output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_instance_endpoint" {
  value = aws_db_instance.aurora_instance.endpoint
}
