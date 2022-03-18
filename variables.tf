#
# The following variables cannot have defaults as they are customer and instance specific
#
variable "project" {
  default     = ""
  description = "GCP project ID"
}

variable "region" {
  default     = ""
  description = "GCP region"
}

variable "zone" {
  default     = ""
  description = "GCP zone"
}

variable "machine_type" {
  default     = ""
  description = "GCP machine type"
}

variable "disk_size" {
  default     = ""
  description = "VM disk size"
}

variable "os_image" {
  default     = ""
  description = "GCP OS image"
}

variable "vm_name" {
  default     = ""
  description = "VM instance name"
}

#
# Default to MIGRATE for the GCP VM maintenance schedule. This can be changed via
# the terraform.tfvars if it needs to be switched to TERMINATE.
#
variable "maintenance" {
  default     = "MIGRATE"
  description = "Host maintenance scheduling"
}

#
# Default to false as most VMs will be standard provision
#
variable "preemptible" {
  default     = "false"
  description = "Determines if this VM instance is preemptible"
}

#
# Specifies if the instance should be restarted if it was terminated by GCE.
# If preemptible is set to true, then this must be set to false.
#
variable "automatic_restart" {
  default     = "true"
  description = "Specifies if the instance should be restarted if it was terminated by GCE"
}

#
# Specifies that the VM may be stopped by GCP for hw/configuration changes.
# If this is set to false then the user must manually stop the VM before
# the change can be completed.
#
variable "allow_stopping_for_update" {
  default     = "true"
  description = "Specifies that the VM may be stopped by GCP for hw/configuration changes"
}
