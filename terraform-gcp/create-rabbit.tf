# Configure the Google Cloud provider
provider "google" {
  credentials = file("<PATH_TO_YOUR_GCP_SERVICE_ACCOUNT_KEY>")
  project     = "<YOUR_GCP_PROJECT_ID>"
  region      = "us-central1"
}

# Create a Google Compute Engine instance
resource "google_compute_instance" "rabbitmq_instance" {
  name         = "rabbitmq-instance"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y rabbitmq-server

    # Enable RabbitMQ Management Plugin
    rabbitmq-plugins enable rabbitmq_management

    # Start RabbitMQ service
    systemctl start rabbitmq-server
    systemctl enable rabbitmq-server
  EOF
}

# Output the external IP address of the RabbitMQ instance
output "external_ip" {
  value = google_compute_instance.rabbitmq_instance.network_interface.0.access_config.0.assigned_nat_ip
}
