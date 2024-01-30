#EC2 instance containing generated SSH keys

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.8.8"
    }
  }
}

provider "local" {
  version = "2.0.0"
}

provider "tls" {
  version = "3.8.8"
}

resource "tls_private_key" "ssh_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

data "local_file" "cloud_config" {
  content  = templatefile("${path.module}/cloud-config.yaml.tpl", {
    public_key  = tls_private_key.ssh_key.public_key_openssh
    private_key = tls_private_key.ssh_key.private_key_pem
  })

  filename = "cloud-config.yaml"
}
