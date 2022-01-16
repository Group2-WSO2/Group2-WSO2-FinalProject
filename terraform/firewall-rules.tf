# allow http traffic
resource "google_compute_firewall" "allow_http" {
  name = "${var.app_name}-fw-allow-bastion"
  network = var.webapp_vpc
  allow {
    protocol = "all"
  }
  target_tags = ["kube","db"]
  source_ranges = ["10.11.0.0/24","10.10.0.0/16"]
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_firewall" "fw_hc" {
  name          = "allow-load-balancers"
  direction     = "INGRESS"
  network       = var.webapp_vpc
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
  source_tags = ["kube","ssh"]
  depends_on = [google_compute_network.webapp_vpc]
}

resource "google_compute_firewall" "fw_db" {
  name          = "allow-db"
  direction     = "INGRESS"
  network       = var.webapp_vpc
  source_ranges = ["10.10.0.0/16", "10.12.0.0/16"]
  allow {
    protocol = "tcp"
  }
  source_tags = ["db","ssh"]
  depends_on = [google_compute_network.webapp_vpc]
}