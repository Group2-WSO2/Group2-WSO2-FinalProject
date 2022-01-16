resource "google_compute_address" "db_load_balancer_ip_asia" {
  name         = "db-lb-ip-asia"
  subnetwork   = google_compute_subnetwork.private_subnet_asia.id
  address_type = "INTERNAL"
  address      = var.db_lb_ip_asia
  region       = var.region_asia
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_forwarding_rule" "db_loadbalancer_asia" {
  name                  = "db-api-loadbalancer-asia"
  backend_service       = google_compute_region_backend_service.db_backend_asia.id
  region                = var.region_asia
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = false
  network               = var.webapp_vpc
  subnetwork            = google_compute_subnetwork.private_subnet_asia.id
  network_tier          = "PREMIUM"
  ip_address            =  google_compute_address.db_load_balancer_ip_asia.address
  service_label         = "db"
  depends_on = [google_compute_network.webapp_vpc,google_compute_subnetwork.private_subnet_asia]
}

output "db_load_balancer_ip_address_asia" {
  value = google_compute_forwarding_rule.db_loadbalancer_asia.ip_address
}

# backend service
resource "google_compute_region_backend_service" "db_backend_asia" {
  name                  = "db-backend-asia"
  region                = var.region_asia
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  depends_on = [google_compute_network.webapp_vpc]
  health_checks         = [google_compute_region_health_check.db_asia.id]
  backend {
    group           = google_compute_instance_group.db_asia[0].id
    balancing_mode  = "CONNECTION"
  }
  backend {
    group           = google_compute_instance_group.db_asia[1].id
    balancing_mode  = "CONNECTION"
  }
  backend {
    group           = google_compute_instance_group.db_asia[2].id
    balancing_mode  = "CONNECTION"
  }
}


# health check
resource "google_compute_region_health_check" "db_asia" {
  name     = "db-healthcheck-asia"
  #provider = google_beta
  depends_on = [google_compute_network.webapp_vpc]
  region   = var.region_asia
  tcp_health_check {
    port = "3306"
  }
  
}

resource "google_compute_instance_group" "db_asia" {
  count = 3
  name = "${var.app_name}-db-asia-${count.index}"
  zone = var.zones_asia[count.index]
  depends_on = [google_compute_network.webapp_vpc]
  instances = [
    google_compute_instance.db_asia[count.index].self_link,
  ]
  named_port {
    name = "mysql"
    port = "3306"
  }
}