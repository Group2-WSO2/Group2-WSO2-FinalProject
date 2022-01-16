# WSO2 Group 2 Final Project

## Requirement

An  Asset Registry web application for users in multiple regions to store and manage asset data in a company, and to perform searches and generate reports on this asset data, This project must;

- Be written in modularized terraform and ansible code.
- Be Highly available and highly resilient in all layers.
- Use a Centralized Logging Solution.
- Have Databases that are are live replicated cross-region.
- Connect the user to the deployment in the closest region to them.

## Proposed Solution

 An Industry standard PAAS built on GCP using native Kubernetes among many other open source tools.

 This is how we addressed each requirement individually.

- Kubernetes to host our web and cache layer in a containerized form.
  - Load-balancing    - Nginx community Ingress. 
  - Auto Scaling          - Horizontal Pod Autoscaling (HPA). 
  - High Availability - HA Setup in 3 different availability zones and with multiple masters and worker nodes.

- Geo-based routing done using Bind:  Users allowed to get connected to deployment which are closed to them.
- MySQL Galera Cluster to create multiple database nodes across multi regions and availability zones: Data in each region is kept in sync with each other and high availability ensured.

## Technologies Used

- Google Cloud Platform ([GCP](https://cloud.google.com/))
- Ansible
- Terraform
- Kubernetes
- Bind9
- Elasticsearch
- Django
- MariaDB (Galera Cluster)
- Redis

## Architecture 

> ![Archite](https://user-images.githubusercontent.com/75664650/149651001-b96b6e7b-aea2-4d55-920a-19c040aee90e.jpg) 

> ![image](https://user-images.githubusercontent.com/75664650/149650960-206ee8c9-61b4-4913-95f1-e361a26c0c67.png)

## Deployment Guide 

1. Create a new project in google cloud console.
2. Generate a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) for the created project. Replace the content in the `group2-sa-key.json` file with the content in the generated service key.
3. Reserve three regional public IP addresses (two for the name servers and one for the Bastion server in their respective regions), two Global public IP addresses for the load balancers.
4. Register a domain and point the two nameserver public IPs on the domain registrar's portal.
5. Generate a public and private key pair. Used command - `ssh-keygen -t rsa`
6. Replace the private-key file in the repo with the generated private key.
7. Add the generated public key to google cloud project [metadata](https://medium.com/@rajeshkanna_a/google-cloud-platform-adding-or-removing-project-wide-public-ssh-keys-5e3fcf22f75d).
8. Create a VM for the bastion server in the region same as the public ip which is allocated for the Bastion server. [Assign](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#assign_new_instance) the public IP address to the Bastion server.
9. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on the Bastion server.
10. Clone the repository into the Bastion server. `git clone [REPO LINK GOES HERE]` command can be used to achieve this.
11. Configure the following files in the repository.
    - terraform/terraform.tfvars:
      - Change the configuration details as required
      ```
      ns_ips = []  //Add the two regional public IP addresses.
      bastion_ip = //Bastion server IP address
      elb_asia_ip = //Load balancer global IP address
      elb_usa_ip = //Load balancer global IP address
      ```
     - ansible/roles/ns-config/vars/main.yml
       - Change the `asia_ip` and `usa_ip` to two load balancer Global public IPs.
       - Change the  `master_ip` and `slave_ip` to the **two name server IPs**
     - ansible/inventory
       - Change the `ns1` and `ns2` name server IPs.
12. Run the `terraform init` command inside the terraform folder.
13. Run the Ansible playbook `execution.yaml`.

> Apart from creating the initial project requirements on GCP and creating/running the ansible host, **Every other part of this entire project is automated in ansible and terraform**.

## Future Improvements

- Ability to easily provision multiple, identical PAAS as DEV STAGE PROD Environments.
- CI/CD Pipeline for IAC, complete with testing tools for IAC included for when changes are made to IAC.
- CI/CD Pipeline for the Developers with testing and DevSecOps that will build and deploy images.
- Internal Docker Registry for cache-ing and private images.
- Disaster Recovery Zone with Live Replication.
- Ability to easily scale to multiple regions.
- Externally hosted Observability and Monitoring solution.
- Modern UI for Webapp using ReactJS frontend and Django Backend.

























