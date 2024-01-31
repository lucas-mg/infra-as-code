# Configure the Google Cloud provider
provider "google" {
  credentials = file("<PATH_TO_YOUR_GCP_SERVICE_ACCOUNT_KEY>")
  project     = "<YOUR_GCP_PROJECT_ID>"
  region      = "us-central1"
}

# Create a Google Kubernetes Engine (GKE) cluster
resource "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = "us-central1"
  
  remove_default_node_pool = true  # Remove the default node pool created by GKE

  initial_node_count = 3  # Number of nodes in the default node pool

  node_pool {
    name       = "default-pool"
    machine_type = "n1-standard-2"
    disk_size_gb  = 100
  }
}

# Output the kubeconfig for accessing the cluster
output "kubeconfig" {
  value = google_container_cluster.my_cluster.master_auth.0.kubeconfig.0.raw_config
}
