#!/bin/bash

# Export environment variables of project and user's email
export PROJECT=using-terraf-156-817a6acd
export USER_EMAIL=cloud_user_p_fa024658@linuxacademygclabs.com

# Generating tf files from templates
envsubst < ./initial/terraform.template > initial/terraform.tfvars
envsubst < ./terraform.template > terraform.tfvars
envsubst < ./providers.template > providers.tf

# Create "mainsa" service account
gcloud iam service-accounts create mainsa --description="Main service account" \
	--display-name="mainsa"

# Assigns basic project editor role for mainsa service account
gcloud projects add-iam-policy-binding ${PROJECT} \
	--member="serviceAccount:mainsa@${PROJECT}.iam.gserviceaccount.com" \
	--role="roles/editor"

# Assigns service account token creator role to user for mainsa SA
gcloud iam service-accounts add-iam-policy-binding \
	mainsa@${PROJECT}.iam.gserviceaccount.com \
	--member="user:${USER_EMAIL}" \
	--role="roles/iam.serviceAccountTokenCreator"

# Enable compute engine & GKE API in project
gcloud services enable \
	compute.googleapis.com \
	container.googleapis.com --project $PROJECT

