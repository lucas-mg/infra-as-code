# Provider Configuration
provider "google" {
  credentials = file("<PATH_TO_YOUR_GCP_SERVICE_ACCOUNT_KEY>")
  project     = "<YOUR_GCP_PROJECT_ID>"
  region      = "us-central1"
}

# Create VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.1.0/24"
}

# Create Kubernetes Cluster
resource "google_container_cluster" "kubernetes_cluster" {
  name     = "my-kubernetes-cluster"
  location = "us-central1"

  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Create MySQL Database
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-instance"
  database_version = "MYSQL_5_7"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

# Create Redis Instance
resource "google_redis_instance" "redis_instance" {
  name     = "redis-instance"
  location = "us-central1"
  tier     = "BASIC"

  redis_version = "REDIS_5_0"
}

# Create MongoDB Atlas Cluster (Replace with your MongoDB Atlas configuration)
resource "mongodbatlas_cluster" "mongo_cluster" {
  cluster_name  = "mongo-cluster"
  provider_name = "GCP"

  num_shards      = 1
  replication_factor = 3

  instance_size_name   = "M10"
  provider_backup_enabled = true
  provider_disk_size_gb  = 40

  labels = {
    environment = "dev"
  }
}
