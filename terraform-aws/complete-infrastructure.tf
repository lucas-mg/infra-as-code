# if you preferred you can rename this file to be main.tf

provider "aws" {
  region = "us-east-1" # North Virginia
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}

# Subnets
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

# Add more subnets as needed...

# Security Groups
resource "aws_security_group" "internal_access" {
  name        = "internal_access"
  description = "Allow internal access only"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.internal_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.internal_access.id]
  }
}

# Load Balancers for Databases
resource "aws_lb" "internal_lb_postgres" {
  name               = "internal-lb-postgres"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_access.id]
  subnets            = [aws_subnet.subnet1.id] # Add more subnets if needed
}

resource "aws_lb" "internal_lb_redis" {
  name               = "internal-lb-redis"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_access.id]
  subnets            = [aws_subnet.subnet1.id] # Add more subnets if needed
}

resource "aws_lb" "internal_lb_docdb" {
  name               = "internal-lb-docdb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_access.id]
  subnets            = [aws_subnet.subnet1.id] # Add more subnets if needed
}

# Kubernetes Cluster (using EKS)
module "eks_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  subnets         = [aws_subnet.subnet1.id] # Add more subnets if needed
  vpc_id          = aws_vpc.my_vpc.id
  node_groups     = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

# Internet-facing Load Balancer for Kubernetes
resource "aws_lb" "external_lb_kubernetes" {
  name               = "external-lb-kubernetes"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id] # Add more subnets if needed
}

# PostgreSQL Database (RDS)
resource "aws_db_instance" "my_database" {
  identifier            = "my-postgres-db"
  allocated_storage    = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "12.6"
  instance_class        = "db.t2.micro"
  name                  = "<CHANGE>"
  username              = "<CHANGE>"
  password              = "<CHANGE>"
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.internal_access.id]
  subnet_group_name     = aws_db_subnet_group.my_db_subnet_group.name
}

# Redis (ElastiCache)
resource "aws_elasticache_cluster" "my_redis" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  security_group_ids   = [aws_security_group.internal_access.id]
}

# DocumentDB (MongoDB)
resource "aws_docdb_cluster" "my_docdb" {
  cluster_identifier   = "my-docdb-cluster"
  engine               = "docdb"
  master_username      = "<CHANGE>"
  master_password      = "<CHANGE>"
  backup_retention_period = 5
  vpc_security_group_ids = [aws_security_group.internal_access.id]
  subnet_group_name     = aws_db_subnet_group.my_db_subnet_group.name
}

# S3 Buckets
resource "aws_s3_bucket" "bucket1" {
  bucket = "my-bucket1"
  acl    = "private"
}

# Add more S3 buckets as needed...

# EC2 Instances with EBS volumes
resource "aws_instance" "ec2_instance1" {
  ami             = "ami-xxxxxxxxxxxxxxxxx" # Specify the AMI ID
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet1.id
  key_name        = "your-key-pair"
  security_group  = [aws_security_group.internal_access.id]
}

# Add more EC2 instances with EBS volumes as needed...

# DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id] # Add more subnets if needed
}
