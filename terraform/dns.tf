resource "google_compute_network" "ns_vpc" {
  name = "ns-vpc"
  auto_create_subnetworks = "false" 
  routing_mode = "GLOBAL"
}
resource "google_compute_subnetwork" "subnet_ns" {
  purpose = "PRIVATE"
  name = "${var.app_name}-subnet-ns"
  ip_cidr_range = "20.20.0.0/24"
  network = google_compute_network.ns_vpc.id
  region = "europe-north1"
  depends_on = [google_compute_network.ns_vpc]
}

resource "google_compute_instance" "ns" {
  count = 2
  name  = "nameserver-${count.index}"
  machine_type = "e2-small"
  zone = var.zones_ns[count.index]
  hostname = "nameserver-${count.index}.${var.app_domain}"
  tags = ["ns"]
  depends_on = [google_compute_network.ns_vpc]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  metadata_startup_script = <<-EOF1
      #! /bin/bash
      apt update
      apt-get install bind9 bind9utils bind9-doc -y
      systemctl restart bind9
    EOF1
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_ns.self_link}"
    access_config {
      nat_ip = "${var.ns_ips[count.index]}"
    }
  }
}

resource "google_compute_firewall" "fw_ns" {
  name          = "allow-ns"
  direction     = "INGRESS"
  network       = google_compute_network.ns_vpc.id
  source_ranges = ["0.0.0.0/0"]
   allow {
    protocol = "tcp"
    ports    = ["53"]
  }
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  allow {
    protocol = "icmp"
  }
  source_tags = ["ns"]
  depends_on = [google_compute_network.ns_vpc]
}

resource "google_compute_firewall" "fw_ns_ssh" {
  name          = "allow-ssh-bastion"
  direction     = "INGRESS"
  network       = google_compute_network.ns_vpc.id
  source_ranges = [var.bastion_ip]
   allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["ns"]
  depends_on = [google_compute_network.ns_vpc]
}



