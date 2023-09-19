pipeline {
  agent any
  
  stages {
    stage("Initialize TF") {
      steps {
        sh '''
	  terraform init
	  terraform validate
        '''
      }
    }

    stage("Plan TF") {
      steps {
        sh '''
          terraform plan
        '''
      }
    }
    
    stage("Validate TF") {
      input {
        message "Do you want to proceed with this deployment?"
        ok "Apply"
      }
      steps {
        echo "Accepted"
      }
    }
    
    stage("Apply TF") {
      steps {
        sh '''
	  terraform apply -auto-approve
        '''
      }
    }

    stage("Fetch credentials for cluster") {
      steps {
        sh '''
          gcloud container clusters get-credentials \
              $(terraform output -json gke_info | jq -r '.gke_name') \
              --location $(terraform output -json gke_info | jq -r '.gke_region')
        '''
      }
    }

    stage("Ansible playbook") {
      steps {
	sh '''
	  cat ansible-dep.yml
	'''
      }
    }

    stage("Validate Ansible playbook") {
      input {
        message "Do you accept this playbook?"
        ok "Accept playbook"
      }
      steps {
	echo "Playbook accepted"
      }
    }
	
    stage("Running Ansible playbook") {
      steps {
	ansiblePlaybook(
	  extraVars: [state: 'present'],
	  playbook:'ansible-dep.yml')
      }
    }

    stage("Stop pods deployment") {
      input {
        message "Do you want to stop deployments?"
        ok "Stop"
      }
      steps {
        echo "Stopping deployments"
      }
    }

    stage("Stopping pods deployment") {
      steps {
        ansiblePlaybook(
	  extraVars: [state: 'absent'],
	  playbook:'ansible-dep.yml')
      }
    }
	
    stage("Destroy TF validation") {
      input {
        message "Do you want to destroy deployed infrastructures?"
        ok "Destroy"
      }
      steps {
        echo "Destroy accepted"
      }
    }
	
    stage("Destroy TF") {
      steps {
        sh '''
	  terraform destroy -auto-approve
        '''
      }
    }
  }
}
