resource "google_compute_network" "webapp_vpc" {
  name = var.webapp_vpc
  auto_create_subnetworks = "false" 
  routing_mode = "GLOBAL"
}
########################## Peerings #####################################
resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.webapp_vpc.id
  peer_network = "projects/wso2-final/global/networks/vpc-bastion"
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  peer_network  = google_compute_network.webapp_vpc.id
  network = "projects/wso2-final/global/networks/vpc-bastion"
}

########################## Subnets ######################################
resource "google_compute_subnetwork" "private_subnet_asia" {
  purpose = "PRIVATE"
  name = "${var.app_name}-private-subnet-asia"
  ip_cidr_range = var.private_subnet_asia_cidr
  network = var.webapp_vpc
  region = var.region_asia
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_subnetwork" "private_subnet_usa" {
  purpose = "PRIVATE"
  name = "${var.app_name}-private-subnet-usa"
  ip_cidr_range = var.private_subnet_usa_cidr
  network = var.webapp_vpc
  region = var.region_usa
  depends_on = [google_compute_network.webapp_vpc]
}

######################### NAT ############################################

resource "google_compute_address" "nat_ip_asia" {
  name = "${var.app_name}-nat-ip-asia"
  project = var.project_name
  region  = var.region_asia
}

resource "google_compute_address" "nat_ip_usa" {
  name = "${var.app_name}-nat-ip-usa"
  project = var.project_name
  region  = var.region_usa
}

######################## NAT Router #######################################
resource "google_compute_router" "nat_router_asia" {
  name = "${var.app_name}-nat-router-asia"
  network = var.webapp_vpc
  region = var.region_asia
  depends_on = [google_compute_network.webapp_vpc]
}
resource "google_compute_router" "nat_router_usa" {
  name = "${var.app_name}-nat-router-usa"
  network = var.webapp_vpc
  region = var.region_usa
  depends_on = [google_compute_network.webapp_vpc]
}

######################## NAT Gateway #######################################

resource "google_compute_router_nat" "nat_gateway_asia" {
  name = "${var.app_name}-nat-gateway-asia"
  router = google_compute_router.nat_router_asia.name
  region = var.region_asia
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ google_compute_address.nat_ip_asia.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
  depends_on = [ google_compute_address.nat_ip_asia, google_compute_network.webapp_vpc ]
  
}

resource "google_compute_router_nat" "nat_gateway_usa" {
  name = "${var.app_name}-nat-gateway-usa"
  router = google_compute_router.nat_router_usa.name
  region = var.region_usa
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ google_compute_address.nat_ip_usa.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
  depends_on = [ google_compute_address.nat_ip_usa, google_compute_network.webapp_vpc ]
  
}

output "nat_ip_address_asia" {
  value = google_compute_address.nat_ip_asia.address
}

output "nat_ip_address_usa" {
  value = google_compute_address.nat_ip_usa.address
}



