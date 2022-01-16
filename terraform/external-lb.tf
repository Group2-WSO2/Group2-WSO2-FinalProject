####################### External groups ##############################
resource "google_compute_instance_group" "external_groups_asia" {
  count = 3
  name = "${var.app_name}-external-group-asia-${count.index}"
  description = "Web servers instance group asia"
  zone = var.zones_asia[count.index]
  depends_on = [google_compute_network.webapp_vpc]
  instances = [
    google_compute_instance.worker_asia[count.index].self_link
  ]
  named_port {
    name = "http"
    port = "30080"
  }
  named_port {
    name = "https"
    port = "30443"
  }
}

resource "google_compute_instance_group" "external_groups_usa" {
  count = 3
  name = "${var.app_name}-external-group-usa-${count.index}"
  description = "Web servers instance group usa"
  zone = var.zones_usa[count.index]
  depends_on = [google_compute_network.webapp_vpc]
  instances = [
    google_compute_instance.worker_usa[count.index].self_link
  ]
  named_port {
    name = "http"
    port = "30080"
  }
  named_port {
    name = "https"
    port = "30443"
  }
}

###################### Healthcheck ##################################

resource "google_compute_health_check" "healthcheck_asia" {
  name = "${var.app_name}-external-healthcheck-asia"
  timeout_sec = 1
  check_interval_sec = 5
  depends_on = [google_compute_network.webapp_vpc]
  http_health_check {
    port = 30080
    request_path = "/healthz"
  }
}

resource "google_compute_health_check" "healthcheck_usa" {
  name = "${var.app_name}-external-healthcheck-usa"
  timeout_sec = 1
  check_interval_sec = 5
  depends_on = [google_compute_network.webapp_vpc]
  http_health_check {
    port = 30080
    request_path = "/healthz"
  }
}

##################### Backend Services ###############################

resource "google_compute_backend_service" "backend_service_asia" {
  name = "${var.app_name}-backend-service-asia"
  project = "${var.project_name}"
  port_name = "http"
  protocol = "HTTP"
  depends_on = [google_compute_network.webapp_vpc]
  health_checks = ["${google_compute_health_check.healthcheck_asia.self_link}"]
  backend {
    group = google_compute_instance_group.external_groups_asia[0].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group = google_compute_instance_group.external_groups_asia[1].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group = google_compute_instance_group.external_groups_asia[2].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
}

resource "google_compute_backend_service" "backend_service_usa" {
  name = "${var.app_name}-backend-service-usa"
  project = "${var.project_name}"
  port_name = "http"
  protocol = "HTTP"
  depends_on = [google_compute_network.webapp_vpc]
  health_checks = ["${google_compute_health_check.healthcheck_usa.self_link}"]
  backend {
    group = google_compute_instance_group.external_groups_usa[0].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group = google_compute_instance_group.external_groups_usa[1].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group = google_compute_instance_group.external_groups_usa[2].self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
}

#################### URL MAP ##################################################

resource "google_compute_url_map" "url_map_asia" {
  name = "${var.app_name}-external-load-balancer-asia"
  project = var.project_name
  default_service = google_compute_backend_service.backend_service_asia.self_link
}

resource "google_compute_url_map" "url_map_usa" {
  name = "${var.app_name}-external-load-balancer-usa"
  project = var.project_name
  default_service = google_compute_backend_service.backend_service_usa.self_link
}

################### target proxy ################################################
resource "google_compute_ssl_certificate" "ssl_certs" {
  name_prefix = "tls-certificate-"
  private_key = file("../certs/key.pem")
  certificate = file("../certs/certificate.pem")

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "target_https_proxy_asia" {
  name = "${var.app_name}-proxy-asia-https"
  ssl_certificates = [google_compute_ssl_certificate.ssl_certs.id]
  project = var.project_name
  url_map = google_compute_url_map.url_map_asia.self_link
}

resource "google_compute_target_https_proxy" "target_https_proxy_usa" {
  name = "${var.app_name}-proxy-usa-https"
  ssl_certificates = [google_compute_ssl_certificate.ssl_certs.id]
  project = var.project_name
  url_map = google_compute_url_map.url_map_usa.self_link
}

####################### forwading rules ###########################################
resource "google_compute_global_forwarding_rule" "global_forwarding_rule_asia_https" {
  name = "${var.app_name}-external-load-balancer-asia-https"
  project = var.project_name
  ip_address = var.elb_asia_ip
  target = google_compute_target_https_proxy.target_https_proxy_asia.self_link
  port_range = "443"
}

resource "google_compute_global_forwarding_rule" "global_forwarding_rule_usa_https" {
  name = "${var.app_name}-external-load-balancer-usa-https"
  project = var.project_name
  ip_address = var.elb_usa_ip
  target = google_compute_target_https_proxy.target_https_proxy_usa.self_link
  port_range = "443"
}

##################### https redirect ####################################
resource "google_compute_url_map" "url_map_redirect_asia" {
  name = "${var.app_name}-external-load-balancer-redirect-asia"
  project = var.project_name
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"  // 301 redirect
    strip_query            = false
    https_redirect         = true  // this is the magic
  }
}

resource "google_compute_url_map" "url_map_redirect_usa" {
  name = "${var.app_name}-external-load-balancer-redirect-usa"
  project = var.project_name
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"  // 301 redirect
    strip_query            = false
    https_redirect         = true  // this is the magic
  }
}

################### target proxy ################################################

resource "google_compute_target_http_proxy" "target_http_redirect_asia" {
  name = "${var.app_name}-redirect-asia"
  project = var.project_name
  url_map = google_compute_url_map.url_map_redirect_asia.self_link
}

resource "google_compute_target_http_proxy" "target_http_redirect_usa" {
  name = "${var.app_name}-redirect-usa"
  project = var.project_name
  url_map = google_compute_url_map.url_map_redirect_usa.self_link
}

####################### forwading rules ###########################################
resource "google_compute_global_forwarding_rule" "global_forwarding_rule_redirect_asia" {
  name = "${var.app_name}-external-load-balancer-asia"
  project = var.project_name
  ip_address = var.elb_asia_ip
  target = google_compute_target_http_proxy.target_http_redirect_asia.self_link
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "global_forwarding_redirect_rule_usa" {
  name = "${var.app_name}-external-load-balancer-usa"
  project = var.project_name
  ip_address = var.elb_usa_ip
  target = google_compute_target_http_proxy.target_http_redirect_usa.self_link
  port_range = "80"
}