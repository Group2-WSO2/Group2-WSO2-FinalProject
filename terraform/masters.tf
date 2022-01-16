resource "google_compute_instance" "master_asia" {
  count = 3
  name  = "kubemaster-asia-${count.index}"
  machine_type = "e2-small"
  zone = var.zones_asia[count.index]
  hostname = "${var.app_name}-kubemaster-asia-${count.index}.${var.app_domain}"
  tags = ["ssh","http","https","kube"]
  depends_on = [google_compute_network.webapp_vpc]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.private_subnet_asia.self_link}"
    network_ip = "${var.kubemaster_ips_asia[count.index]}"
  }
}


resource "google_compute_instance" "master_usa" {
  count = 3
  name  = "kubemaster-usa-${count.index}"
  machine_type = "e2-small"
  zone = var.zones_usa[count.index]
  hostname = "${var.app_name}-kubemaster-usa-${count.index}.${var.app_domain}"
  tags = ["ssh","http","https","kube"]
  depends_on = [google_compute_network.webapp_vpc]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.private_subnet_usa.self_link}"
    network_ip = "${var.kubemaster_ips_usa[count.index]}"
  }
}
