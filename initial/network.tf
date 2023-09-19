# Create simple VPC, can be omitted if using default VPC
resource "google_compute_network" "auto-net" {
  name = var.vpc-name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "auto-subnet" {
  name			= var.vpc-subnet-name
  ip_cidr_range = var.cidr.main
  region		= var.region
  network		= google_compute_network.auto-net.id
  
  secondary_ip_range {
    range_name = "${var.vpc-subnet-name}-pods"
	ip_cidr_range = var.cidr.secondary_pods
  }
  
  secondary_ip_range {
    range_name = "${var.vpc-subnet-name}-services"
	ip_cidr_range = var.cidr.secondary_services
  }
}

resource "google_compute_firewall" "ssh" {
  name = "sa-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.auto-net.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  source_service_accounts = ["mainsa@${var.project}.iam.gserviceaccount.com"]
  target_service_accounts = ["mainsa@${var.project}.iam.gserviceaccount.com"]
}

resource "google_compute_firewall" "allow-ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.auto-net.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow-http" {
  name = "allow-http"
  allow {
    ports    = ["80", "8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.auto-net.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}
