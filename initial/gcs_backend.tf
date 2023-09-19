resource "google_storage_bucket" "backend" {
  name			= "${var.project}-tf-backend"
  location		= var.region
  force_destroy = true
  public_access_prevention = "enforced"
  
  versioning {
    enabled = true
  }
}
