module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project
  name                       = "${var.project}-gke-server"
  region		     = var.region
  zones			     = ["${var.zone}"]
  network                    = var.vpc-name
  subnetwork                 = var.vpc-subnet-name
  ip_range_pods		     = "${var.vpc-subnet-name}-pods"
  ip_range_services	     = "${var.vpc-subnet-name}-services"
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  create_service_account     = false
  service_account	     = "mainsa@${var.project}.iam.gserviceaccount.com"
  remove_default_node_pool   = true
  logging_service	     = "logging.googleapis.com/kubernetes"

  node_pools = [
    {
      name                      = "node-pool"
      machine_type              = "e2-medium"
      min_count                 = 1
      max_count                 = 4
      spot                      = false
      disk_size_gb              = 50
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      auto_repair               = true
      auto_upgrade              = true
      autoscaling		= true
      initial_node_count        = 1
    },
  ]
  
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
  
  node_pools_labels = {
    all = {}
    default-node-pool = {
      default-node-pool = true
    }
  }
  
  node_pools_tags = {
    all = []
    node-pool = [
      "allow-http",
    ]
  }
}

output "gke_info" {
  value = {
    gke_name   = module.gke.name
    gke_region = module.gke.region
  }
}

