# Automatic deployment with Terraform, Jenkins and Ansible integration on Google Cloud Platform 

This repo serves as an example how Terraform, Jenkins and Ansible can be integrated to deploy VM for automating GKE and containerized deployment.

Main steps in this demo are as follow:

- Provision Google Compute Engine (GCE) serving as Jenkins, Terraform and Ansible server
- Provision Cloud Bucket serving as Terraform backend
- Automatically deploy GKE using Jenkins pipeline project
- Deploy nginx pod in GKE using Ansible `core.k8s` module

## Table of Contents
- [1. Software version](#1-software-version)
- [2. Deploy GCE & Cloud Bucket](#2-deploy-gce-&-cloud-bucket)
	- [2.1. Install gcloud CLI & Terraform on your local machine](#21-install-gcloud-cli-&-terraform-on-your-local-machine)
	- [2.2. Setting up project & user account email values](#22-setting-up-project-&-user-account-email-values)
	- [2.3. Deploy GCE & Cloud Bucket backend](#23-deploy-gce-&-cloud-bucket-backend)
- [3. Setting up GCE deployment automation server](#3-setting-up-gce-deployment-automation-server)
	- [3.1. Install Terraform, Jenkins & Ansible on GCE](#31-install-terraform-jenkins-&-ansible-on-gce)
	- [3.2. Get GitHub personal access token](#32-get-github-personal-access-token)
	- [3.3. Configuring Jenkins](#33-configuring-jenkins)
	- [3.4. Create Pipeline project](#34-create-pipeline-project)
- [4. Cleanup](#4-cleanup)

## 1. Software version

| Software | Version |
| --- | --- |
| Google Cloud SDK | 446.0.0 |
| Terraform | 1.5.7 |
| Jenkins | 2.414.1 |
| Ansible | 2.14.9 |

## 2. Deploy GCE & Cloud Bucket

In order to use this repo, you can fork this repo into your GitHub account.

This repo sets the default deployment region and zone to `us-west1` and `us-west1-b` respectively.

### 2.1. Install gcloud CLI & Terraform on your local machine

To start things off, you must install gcloud CLI and Terraform on your local machine in order to deploy infrastructures on your GCP project.

You can follow the appropiate install instruction for your OS over on [Google Cloud](https://cloud.google.com/sdk/docs/install) and [Terraform](https://developer.hashicorp.com/terraform/downloads).

### 2.2. Setting up project & user account email values

To get started using gcloud CLI on your local machine, the first step is to log into your account and project by executing following command:

```sh
gcloud init
```

After executing above command, you will be given link that you can copy to your browser and log into your user account to authorize gcloud CLI by pasting generated authorization key.

Following the same pattern, authorize your local gcloud to use service account that will be bound to your user account by executing this:

```sh
gcloud auth application-default login
```

Instead of downloading service account key on local machine which may pose security risk, this allows you to use & impersonate service account in a more convenient and secure way (as per [Google's recommendation](https://cloud.google.com/docs/authentication)).

From here, you need to replace the following values in `start.sh`:

- `<gcp_project>`: GCP project you're planning to deploy into
- `<user_email>`: Your user account email for the project

The next step after replacing those values, execute `start.sh` script.

This script serves 4 main functions:
1. Generate `.tfvars` and `.tf` files necessary for GCP infrastructure provisioning made through Terraform.
2. Create `mainsa` service account (SA), which then will be assigned with Editor role.
3. Bind your user account with Service Account Token Creator role for the SA.
4. Enable Compute Engine and Google Kubernetes Engine API in your project.

After executing the script, you can commit the changes made in your forked repo as that repo will be executed by Jenkins later on.

### 2.3. Deploy GCE & Cloud Bucket backend

Now you're all set to deploy GCE and Cloud Bucket in your project. Head on to `initial` directory and execute the following commands:

```sh
terraform init
terraform plan
# Make sure to check the deployment is set correctly before proceeding
terraform apply -auto-approve
```

Note: Please allow the role binding to fully propagate before running `terraform apply -auto-approve` command.

Terraform files in this directory are configured to provision a CentOS Stream 9 GCE, VPC (along with subnetwork, pre-assigned IP CIDR & firewall rules) and Cloud Bucket with object versioning enabled.

## 3. Setting up GCE deployment automation server

To avoid overcomplicating this demo, Terraform, Jenkins and Ansible server will be set up on the same GCE.

### 3.1. Install Terraform, Jenkins & Ansible on GCE

After GCE, VPC and bucket backend has been successfully provisioned, we'll need to install all the required softwares in order to turn this GCE into an automated deployment server.

Still within the `initial` directory, you can copy `install.sh` script which install necessary softwares and their respective dependencies in the newly provisioned GCE with this command:

```sh
gcloud compute scp install.sh $(terraform output -json init_deployment_info | jq -r '.gce_server'):~
```

Alternatively, you can just go straight to ssh into the GCE using:

```sh
gcloud compute ssh $(terraform output -json init_deployment_info | jq -r '.gce_server') --zone $(terraform output -json init_deployment_info | jq -r '.gce_zone')
```

From within the GCE, you can create `install.sh` using preinstalled vim and copy the code yourself. Don't forget to execute `chmod +x install.sh` if you chose to do so.

After you have logged into the GCE, you can start running `install.sh` to install all the necessary programs.

### 3.2. Get GitHub personal access token

To enable webhook between Jenkins and your GitHub, you have to create an access token with the necessary permissions over on your GitHub account.

From your GitHub account page, click your profile on the top right corner and go to `Settings` > `Developer settings` > `Personal access tokens` > `Tokens (classic)`.

Generate new classic token, fill out the note, set your expiration date, check `admin:repo_hook` and select `Generate token`.

Copy the generated token and save it in a secure place. This token will be shown only once and you need to generate new token again if you lost it.

### 3.3. Configuring Jenkins

After `install.sh` has finished running, you will get Jenkins' initial admin password. Use this to log into Jenkins on `<GCE External IP>:8080` through your browser.

Proceed with the initialization as instructed by Jenkins and install recommended plugins.

After plugins installation has finished, you can go to `Manage Jenkins` > `Plugins` > `Available plugins`, search for Ansible plugin, install it and check the "Restart after finished" box.

The next step is to enter your Git credential over on `Manage Jenkins` > `Credentials` > `(global)`.

Add credential and then choose username with password. Fill the username with your GitHub username and password with the generated token.


### 3.4. Create Pipeline project

From the left panel of main page, select New item and create a new Pipeline project. Check `GitHub hook trigger for GITScm polling` box to enable webhook build trigger.

Set the definition of the pipeline from SCM, use Git SCM, fill out the link to your forked repo in `Repository URL` and use the credential that we have set up.

Save the configuration and the first build should start immediately. Check the build process from the `Stage View` and approve any build prompts that pops up.

After GKE has been provisioned and pods are deployed successfully, you can check the external IP of the Load Balancer service by obtaining credentials to the deployed GKE cluster first:

```sh
gcloud container clusters get-credentials <GKE_cluster_name>
kubectl get services -n nginx
```

## 4. Cleanup

You can stop nginx pods deployment and destroy provisioned GKE by approve the deployment deletion and infra destruction from the project's `Stage View`.

To destroy the GCE automation server along with the installed softwares, just head back to `initial` directory on your local machine and execute:

```sh
terraform destroy -auto-approve
```
