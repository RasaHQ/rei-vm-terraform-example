#
# This file causes terraform to echo these outputs to the terminal upon completion
#

output "name" {
  value = var.vm_name
}

output "ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "zone" {
  value = var.zone
}

output "sshcmd" {
  value = "gcloud compute ssh ${var.vm_name} --zone=${var.zone}"
}
