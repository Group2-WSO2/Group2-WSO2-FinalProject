resource "google_compute_address" "load_balancer_ip_asia" {
  name         = "lb-ip-asia"
  subnetwork   = google_compute_subnetwork.private_subnet_asia.id
  address_type = "INTERNAL"
  address      = var.kube_api_server_internal_lb_asia
  region       = var.region_asia
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_forwarding_rule" "kube_api_loadbalancer_asia" {
  name                  = "kube-api-loadbalancer-asia"
  backend_service       = google_compute_region_backend_service.kube_backend_asia.id
  region                = var.region_asia
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = false
  network               = var.webapp_vpc
  subnetwork            = google_compute_subnetwork.private_subnet_asia.id
  network_tier          = "PREMIUM"
  ip_address            =  google_compute_address.load_balancer_ip_asia.address
  service_label         = "kube-api-server-asia"
  depends_on = [google_compute_network.webapp_vpc,google_compute_subnetwork.private_subnet_asia]
}

output "kubeapi_load_balancer_ip_address_asia" {
  value = google_compute_forwarding_rule.kube_api_loadbalancer_asia.ip_address
}

# backend service
resource "google_compute_region_backend_service" "kube_backend_asia" {
  name                  = "kube-master-backend-asia"
  region                = var.region_asia
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  depends_on = [google_compute_network.webapp_vpc]
  health_checks         = [google_compute_region_health_check.kube_healthcheck_asia.id]
  backend {
    group           = google_compute_instance_group.kubemasters_asia[0].id
    balancing_mode  = "CONNECTION"
  }
}


# health check
resource "google_compute_region_health_check" "kube_healthcheck_asia" {
  name     = "kube-master-healthcheck-asia"
  #provider = google_beta
  depends_on = [google_compute_network.webapp_vpc]
  region   = var.region_asia
  tcp_health_check {
    port = "6443"
  }
  
}

resource "google_compute_instance_group" "kubemasters_asia" {
  count = 3
  name = "${var.app_name}-kubemaster-group-asia-${count.index}"
  zone = var.zones_asia[count.index]
  depends_on = [google_compute_network.webapp_vpc]
  instances = [
    google_compute_instance.master_asia[count.index].self_link,
  ]
  named_port {
    name = "tcp"
    port = "6443"
  }
  named_port {
    name = "web"
    port = "80"
  }
}




