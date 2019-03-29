# Terraform, Ansible and HA load balancing in the IBM Cloud

## **Major Work in Progress** 

## Overview
This tutorial will show how to automate the provisioning of infrastructure resources in IBM Cloud by using and Ansible. Terraform will be our deployment tool and Ansible will take on the configuration tasks for our pool of web servers and HA pair of HAProxy instances. 

### Slightly longer version
One of my colleagues, *Hi Neil!*, wrote a [guide](https://dsc.cloud/quickshare/HA-NGINX-How-To.pdf) for how to do a roll your own HA Load balancer deployment with Keepalived and Nginx on the IBM Cloud. I decided to take up the learning exercise/challenge of migrating the manual steps in the guide to an automated deployment model using Terraform and Ansible. I also added in an extra wrinkle which is to add Security groups in to the mix. 

## **Major Work in Progress** 
#### Todo:
 - [x] Deployment of IaaS Load Balancer and Web Servers using Terraform
 - [x] Creation of floating IP for HAProxy boxes.
 - [x] Generation of local Ansible Inventory file.
 - [x] Generation of Ansible playbooks using Terraform template provider
 - [x] Ansible playbooks to add portable IPs to Web and Load balancer nodes
 - [x] Ansible playbooks to install and configure Keepalived
 - [x] Created playbooks for installing Nginx and configuring it to listen on private network IPs. 
 - [x] Created playbook for HAProxy LB config (Keepalived and floating IP are already done). 
 - [ ] Create private subnet for web servers 
 - [ ] Need to configure the `install.yml` file to create a user account that is not named Ryan.
 - [ ] Need to put placeholder in the `install.yml` file for where you can add your specific SSH keys (and not mine). 
 - [ ] Need to dynamically create Security groups based on Subnets that are provisioned.


## Objectives
Here is a simple diagram of what we are trying to accomplish:

![Diagram](https://dsc.cloud/quickshare/haproxy_diagram.png)

## Prerequisites
 - Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install.html)
 - The IBM Cloud Terraform provider [installed and configured](https://ibm-cloud.github.io/tf-ibm-docs/index.html#using-terraform-with-the-ibm-cloud-provider)
 - Since our Web servers will not have public network interfaces you will need one of the following to successfully run the Ansible commands:
    - An active [VPN](https://cloud.ibm.com/docs/terraform/ansible?topic=terraform-ansible#setup_vpn) connection to the IBM Cloud. 
    - A [Bastion host](https://blog.scottlowe.org/2015/12/24/running-ansible-through-ssh-bastion-host/) running on the IBM Cloud. See [Bastion Host](#bastion-host) for additional steps needed. 
    - An existing IBM Cloud server
 
### Bastion host
If you are using a bastion host run the following commands:

```bash
mv main.tf{,.bak}
cp Files/bastion_main.tf.tpl main.tf
```

This alternate `main.tf` file creates a version of the Ansible inventory that includes lines for running commands via a Bastion Host.
