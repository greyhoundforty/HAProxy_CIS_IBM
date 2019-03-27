#!/usr/bin/env bash

dt=$(date +"%m-%d-%Y-%H:%M")

runlog="${dt}-run.log"
export TF_LOG=DEBUG
export TF_LOG_PATH="${dt}-debug.log"

iaas_provision() {
    terraform init --backend-config='~/Sync/Coding/Terraform/backend.tfvars'
    terraform validate -var-file='~/Sync/Coding/Terraform/credentials.tfvars'
        if [ $? -eq 1 ]; then
            echo "Issues with validation" >&2
            exit 1
        fi 
    terraform plan -var-file='~/Sync/Coding/Terraform/credentials.tfvars' -out "iaas.tfplan"
    terraform apply -auto-approve "iaas.tfplan"
    sleep 120
} &> ${runlog}

ansible_config() {
    cd Ansible 
    terraform init
    terraform validate 
         if [ $? -eq 1 ]; then
            echo "Issues with validation" >&2
            exit 1
        fi 
    terraform plan -out "ansible.tfplan"
    terraform apply -auto-approve "ansible.tfplan"
} &> ${runlog}

iaas_provision
ansible_config