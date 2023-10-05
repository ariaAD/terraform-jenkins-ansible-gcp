provider "google" {
  project	  = var.project
  region	  = var.region
  zone		  = var.zone
  impersonate_service_account = "mainsa@${var.project}.iam.gserviceaccount.com"
}

data "google_compute_image" "rocky-linux-9" {
  family      = "rocky-linux-9-optimized-gcp"
  project     = "rocky-linux-cloud"
  most_recent = true
}

# Server for jenkins, terraform & ansible
resource "google_compute_instance" "vm_instance" {
  name			    = "${var.project}-auto-server"
  machine_type		    = "e2-standard-2"
  zone			    = var.zone
  allow_stopping_for_update = true
  tags			    = ["allow-ssh", "allow-http"]
  
  service_account {
    email = "mainsa@${var.project}.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  
  boot_disk {
    initialize_params {
      image = data.google_compute_image.rocky-linux-9.self_link
    }
  }
  
  network_interface {
    network = google_compute_network.auto-net.self_link
    subnetwork = google_compute_subnetwork.auto-subnet.self_link
    access_config {}
  }
}

output "init_deployment_info" {
  value = {
    tf_backend_bucket = google_storage_bucket.backend.name
    gce_server	      = google_compute_instance.vm_instance.name
    gce_zone	      = google_compute_instance.vm_instance.zone
  }
}
