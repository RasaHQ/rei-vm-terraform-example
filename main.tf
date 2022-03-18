// Configure the Google Cloud provider
// No credentials provided here so it will use your gcloud creds (ADC)
provider "google" {
  project = var.project
  region  = var.region
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
  name                      = var.vm_name
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = var.allow_stopping_for_update

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size
    }
  }

  scheduling {
    on_host_maintenance = var.maintenance
  }

  metadata = {
    k8s-helper = file("${path.module}/scripts/k8s-helper.sh")
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  // Optional tags to apply to the VM; could useful for firewall rule matching, as an example
  tags = ["http-server", "https-server"]

  network_interface {
    network = "default"
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}
