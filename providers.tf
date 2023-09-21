terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.73.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
  backend "gcs" {
    bucket = "using-terraf-156-91e68a5c-tf-backend"
    prefix = "terraform/state"
  }
}

provider "google" {
  project	= var.project
  region	= var.region
  zone		= var.zone
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

