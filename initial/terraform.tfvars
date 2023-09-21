project         = "using-terraf-156-817a6acd"
region          = "us-west1"
zone            = "us-west1-b"
vpc-name        = "auto-net"
vpc-subnet-name = "auto-subnet"

cidr = {
  main = "10.2.0.0/16"
  secondary_pods = "10.3.0.0/23"
  secondary_services = "10.3.2.0/23"
}
