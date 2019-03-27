# Terraform, Ansible and HA load balancing in the IBM Cloud

One of my colleagues, *Hi Neil!*, wrote a guide for how to do a roll your own Cloud Load balancer scenerio with Keepalived and Nginx on the IBM Cloud. I decided to take up the learning exercise/challenge of migrating the manual steps in the guide to an automated deployment model using Terraform and Ansible. I also added in an extra wrinkle which is to add Security groups in to the mix. The [overview](#overview) and [Objectives and Outcomes](#objectives-and-outcomes) sections below are lifted directly from Neils guide [here](https://dsc.cloud/quickshare/HA-NGINX-How-To.pdf).

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

## Changes from original guide
I decided to use HAProxy in place of Nginx for the front-end load balancers, and Nginx in place of Apache for the web servers. Additionally all of the systems are running Ubuntu 16.04 as opposed to Centos like in Neil's guide. 

## Overview
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam dolor erat, consectetur ac scelerisque at, porta sit amet ipsum. Vestibulum ac nulla turpis. Fusce fringilla sagittis elit id convallis. Morbi scelerisque diam eget ex interdum, id condimentum justo laoreet. Maecenas molestie malesuada sodales. Nullam convallis sem ac tincidunt malesuada.

## Objectives and Outcomes
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam dolor erat, consectetur ac scelerisque at, porta sit amet ipsum. Vestibulum ac nulla turpis. Fusce fringilla sagittis elit id convallis. Morbi scelerisque diam eget ex interdum, id condimentum justo laoreet. Maecenas molestie malesuada sodales. Nullam convallis sem ac tincidunt malesuada. Sed magna mauris, faucibus vel aliquam eu, aliquam quis lorem. Sed quam augue, scelerisque et ante ac, tristique scelerisque turpis. Nullam ac sollicitudin libero. Nulla varius sapien nisi, ac interdum neque hendrerit sed. Fusce eget purus ut sem iaculis consectetur. Aliquam vel sagittis justo. Cras sed eleifend nulla. Aenean aliquet aliquam pulvinar. In eu aliquet diam, ut convallis diam. Aenean massa ligula, pellentesque eu laoreet at, imperdiet in est. 

We will configure the solution to accept HTTP traffic on the public network, proxy the traffic to the private network, and keep all the servers on the same VLAN, for two specific reasons. The first is that it keeps your web servers secure. You can turn the public network interfaces of your web servers off, thus negating any sort of risk you may face from intrusion attempts. The second is that by keeping everything on the same VLAN, you can take advantage of the native intra-VLAN network and avoid any unnecessary network hops, thus lowering latency and increasing performance.
Here is a simple diagram of what we are trying to accomplish:

![Diagram](https://dsc.cloud/quickshare/haproxy_diagram.png)

## Prerequisites
 - Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install.html)
 - The IBM Cloud Terraform provider [installed and configured](https://ibm-cloud.github.io/tf-ibm-docs/index.html#using-terraform-with-the-ibm-cloud-provider)
 - Since our Web servers are going to be private network only you will need either a [Bastion host](https://en.wikipedia.org/wiki/Bastion_host) or existing IBM Cloud server to run the Ansible commands from. 


