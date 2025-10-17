variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Machine type for instances"
  type        = string
  default     = "e2-medium"
}

variable "domain_names" {
  description = "List of domain names for Google-managed certificate"
  type        = list(string)
  example     = ["example.com", "www.example.com"]
}
