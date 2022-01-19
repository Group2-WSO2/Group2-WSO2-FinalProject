# GCP Settings
region_asia  = "asia-southeast1"
region_usa  = "us-central1"
project_name = "wso2-final" # This is your GCP project name"
auth_key = "../group2-sa-key.json"
app_name = "webapp"
app_domain = "terraform"

kube_api_server_internal_lb_usa="10.12.100.100"
kube_api_server_internal_lb_asia="10.10.100.100"

db_lb_ip_asia="10.10.200.100"
db_lb_ip_usa="10.12.200.100"

webapp_vpc = "webapp-vpc"

ns_ips = ["34.88.47.71","35.228.71.77"]

bastion_ip = "35.198.207.200"

elb_asia_ip = "34.149.54.177"
elb_usa_ip = "35.227.211.154"

zones_ns = [ "europe-north1-a","europe-north1-b"]
zones_asia = [ "asia-southeast1-a","asia-southeast1-b","asia-southeast1-c" ]
zones_usa = [ "us-central1-a","us-central1-b","us-central1-c" ]

db_ips_asia = ["10.10.0.50","10.10.0.51","10.10.0.52"]
db_ips_usa = ["10.12.0.50","10.12.0.51","10.12.0.52"]

kubemaster_ips_asia = ["10.10.0.101","10.10.0.102","10.10.0.103"]
kubeworker_ips_asia = ["10.10.0.201","10.10.0.202","10.10.0.203"]

kubemaster_ips_usa = ["10.12.0.101","10.12.0.102","10.12.0.103"]
kubeworker_ips_usa = ["10.12.0.201","10.12.0.202","10.12.0.203"]

# GCP Netwok
private_subnet_asia_cidr  = "10.10.0.0/16"
private_subnet_usa_cidr  = "10.12.0.0/16"
private_subnet_db_cidr  = "10.14.0.0/16"