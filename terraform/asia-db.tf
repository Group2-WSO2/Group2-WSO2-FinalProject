resource "google_compute_instance" "db_asia" {
  count = 3
  name  = "db-asia-${count.index}"
  machine_type = "e2-small"
  zone = var.zones_asia[count.index]
  hostname = "${var.app_name}-db-asia${count.index}.${var.app_domain}"
  tags = ["ssh","db"]
  depends_on = [google_compute_network.webapp_vpc]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  metadata_startup_script = <<-EOF1
      #! /bin/bash
      apt update
      apt-get install software-properties-common -y
      apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
      sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"
      apt update
      apt -y install mariadb-server mariadb-client
    EOF1
  network_interface {
    subnetwork = "${google_compute_subnetwork.private_subnet_asia.self_link}"
    network_ip = "${var.db_ips_asia[count.index]}"
  }
}
