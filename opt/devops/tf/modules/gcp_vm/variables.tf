variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "zone" {
  description = "Zone for the instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-medium"
}

variable "vpc_network" {
  description = "VPC network self link"
  type        = string
}

variable "vpc_subnetwork" {
  description = "VPC subnetwork self link"
  type        = string
}

variable "image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-11"
}
