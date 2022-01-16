resource "google_compute_address" "db_load_balancer_ip_usa" {
  name         = "db-lb-ip-usa"
  subnetwork   = google_compute_subnetwork.private_subnet_usa.id
  address_type = "INTERNAL"
  address      = var.db_lb_ip_usa
  region       = var.region_usa
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_forwarding_rule" "db_loadbalancer_usa" {
  name                  = "db-api-loadbalancer-usa"
  backend_service       = google_compute_region_backend_service.db_backend_usa.id
  region                = var.region_usa
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = false
  network               = var.webapp_vpc
  subnetwork            = google_compute_subnetwork.private_subnet_usa.id
  network_tier          = "PREMIUM"
  ip_address            =  google_compute_address.db_load_balancer_ip_usa.address
  service_label         = "db"
  depends_on = [google_compute_network.webapp_vpc,google_compute_subnetwork.private_subnet_usa]
}

output "db_load_balancer_ip_address_usa" {
  value = google_compute_forwarding_rule.db_loadbalancer_usa.ip_address
}

# backend service
resource "google_compute_region_backend_service" "db_backend_usa" {
  name                  = "db-backend-usa"
  region                = var.region_usa
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  depends_on = [google_compute_network.webapp_vpc]
  health_checks         = [google_compute_region_health_check.db_usa.id]
  backend {
    group           = google_compute_instance_group.db_usa[0].id
    balancing_mode  = "CONNECTION"
  }
  backend {
    group           = google_compute_instance_group.db_usa[1].id
    balancing_mode  = "CONNECTION"
  }
  backend {
    group           = google_compute_instance_group.db_usa[2].id
    balancing_mode  = "CONNECTION"
  }
}


# health check
resource "google_compute_region_health_check" "db_usa" {
  name     = "db-healthcheck-usa"
  #provider = google_beta
  depends_on = [google_compute_network.webapp_vpc]
  region   = var.region_usa
  tcp_health_check {
    port = "3306"
  }
  
}

resource "google_compute_instance_group" "db_usa" {
  count = 3
  name = "${var.app_name}-db-usa-${count.index}"
  zone = var.zones_usa[count.index]
  depends_on = [google_compute_network.webapp_vpc]
  instances = [
    google_compute_instance.db_usa[count.index].self_link,
  ]
  named_port {
    name = "mysql"
    port = "3306"
  }
}