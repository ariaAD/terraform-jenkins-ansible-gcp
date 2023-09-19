#!/bin/bash

sudo dnf update -y

# Install pip, Ansible & all k8s module dependencies
sudo dnf install python3-pip -y
sudo pip3 install ansible
sudo pip3 install kubernetes
sudo pip3 install pyyaml
sudo pip3 install jsonpatch

# Install yum-utils, adds Terraform repo & install Terraform
sudo yum install yum-utils jq -y
sudo yum-config-manager --add-repo \
	        https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install terraform -y

# Install kubectl & GKE authorizer
sudo dnf install kubectl google-cloud-sdk-gke-gcloud-auth-plugin -y

# Install Jenkins dependencies (Java 17 openjdk & wget)
sudo dnf install java-17-openjdk wget -y

# Add Jenkins repo for Red Hat & install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
	        https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import \
	        https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y
sudo dnf install jenkins -y

# Start Jenkins service
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Print installation messages
echo "Ansible and Terraform have been successfully installed."
ansible --version
terraform version

# Get Jenkins initial password
echo -e "\nJenkins initial admin password"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

