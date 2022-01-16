variable "auth_key" {type = string}
variable "app_name" {type = string}
variable "app_domain" {type = string}
variable "project_name" {type = string}

variable "region_asia" {type = string}
variable "region_usa" {type = string}

variable "bastion_ip" {type = string}

variable "elb_asia_ip" {type = string}
variable "elb_usa_ip" {type = string}

variable "private_subnet_asia_cidr" {type = string}
variable "private_subnet_usa_cidr" {type = string}
variable "private_subnet_db_cidr" {type = string}

variable "db_lb_ip_asia" {type = string}
variable "db_lb_ip_usa" {type = string}
variable "kube_api_server_internal_lb_asia" {type = string}
variable "kube_api_server_internal_lb_usa" {type = string}

variable "db_ips_asia" {type = list(string)}
variable "db_ips_usa" {type = list(string)}

variable "kubemaster_ips_asia" {type = list(string)}
variable "kubeworker_ips_asia" {type = list(string)}
variable "kubemaster_ips_usa" {type = list(string)}
variable "kubeworker_ips_usa" {type = list(string)}

variable "ns_ips" {type = list(string)}
variable "zones_asia" {type = list(string)}
variable "zones_usa" {type = list(string)}
variable "zones_ns" {type = list(string)}
variable "webapp_vpc" {type = string}