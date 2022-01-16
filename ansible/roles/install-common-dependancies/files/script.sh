#!/bin/bash
# sudo apt-get update && sudo apt-get install -y apt-transport-https
# sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
# sudo apt-get update
# sudo apt-get install -y kubelet kubeadm kubectl
# sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
# sudo set -o noclobber 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 
sudo echo  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb-release -cs) stable" | sudo tee  /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo echo 'Environment="cgroup-driver=systemd/cgroup-driver=cgroups"' | sudo tee -a  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf > /dev/null
sudo echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | sudo tee /etc/docker/daemon.json > /dev/null
sudo systemctl daemon-reload
sudo systemctl restart docker