data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

data "ibm_resource_group" "group" {
  name = "CDE"
}

data "ibm_cis" "cis_instance" {
  name              = "cloudintrsvc-rt"
  resource_group_id = "${data.ibm_resource_group.group.id}"
}

data "ibm_cis_domain" "cis_instance_domain" {
  domain = "cloudintrsvc.com"
  cis_id = "${data.ibm_cis.cis_instance.id}"
}

resource "random_id" "name" {
  byte_length = 4
}

resource "ibm_subnet" "floating_ip_subnet" {
  type       = "Portable"
  private    = false
  ip_version = 4
  capacity   = 4
  vlan_id    = "${var.pub_vlan["us-south1"]}"
  notes      = "testing_subnet_tf_rt"
}

resource "ibm_compute_vm_instance" "haproxy_nodes" {
  count                = "${var.node_count["haproxy"]}"
  hostname             = "haproxy${count.index+1}"
  domain               = "${var.domainname}"
  user_metadata        = "${file("haproxy_install.yml")}"
  os_reference_code    = "${var.os["u16"]}"
  datacenter           = "${var.datacenter["us-south1"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  flavor_key_name      = "${var.vm_flavor["medium"]}"
  disks                = [200]
  local_disk           = false
  public_vlan_id       = "${var.pub_vlan["us-south1"]}"
  private_vlan_id      = "${var.priv_vlan["us-south1"]}"
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.deploymentKey.id}"]

  tags = [
    "ryantiffany",
    "terraform-testing",
  ]
}

resource "ibm_compute_vm_instance" "web_nodes" {
  depends_on           = ["ibm_compute_vm_instance.haproxy_nodes"]
  count                = "${var.node_count["web"]}"
  hostname             = "web${count.index+1}"
  domain               = "${var.domainname}"
  user_metadata        = "${file("web_install.yml")}"
  os_reference_code    = "${var.os["u16"]}"
  datacenter           = "${var.datacenter["us-south1"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = true
  flavor_key_name      = "${var.vm_flavor["medium"]}"
  disks                = [200]
  local_disk           = false
  private_vlan_id      = "${var.priv_vlan["us-south1"]}"
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.deploymentKey.id}"]

  tags = [
    "ryantiffany",
    "terraform-testing",
  ]
}

resource "local_file" "ansible_hosts" {
  depends_on = ["ibm_compute_vm_instance.web_nodes"]

  content = <<EOF
[haproxy]
haproxy1 ansible_host=haproxy1.${var.domainname} ansible_user=ryan
haproxy2 ansible_host=haproxy2.${var.domainname} ansible_user=ryan

[haproxy:vars]
host_key_checking = False

[nginx]
web1 ansible_host=web1.ans.${var.domainname} ansible_user=ryan
web2 ansible_host=web2.ans.${var.domainname} ansible_user=ryan
web3 ansible_host=web3.ans.${var.domainname} ansible_user=ryan
web4 ansible_host=web4.ans.${var.domainname} ansible_user=ryan

[nginx:vars]
host_key_checking = False
ssh_args = -F  /Users/ryan/Sync/Coding/Ansible/ssh.cfg -o ControlMaster=auto -o ControlPersist=30m
control_path = ~/.ssh/ansible-%%r@%%h:%%p

[local]
control ansible_connection=local
EOF

  filename = "${path.cwd}/Ansible/inventory.env"
}

resource "ibm_cis_dns_record" "haproxy_records" {
  count     = "${var.node_count["haproxy"]}"
  cis_id    = "${data.ibm_cis.cis_instance.id}"
  domain_id = "${data.ibm_cis_domain.cis_instance_domain.id}"
  name      = "haproxy${count.index+1}"
  content   = "${element(ibm_compute_vm_instance.haproxy_nodes.*.ipv4_address,count.index)}"
  type      = "A"
}

resource "ibm_cis_dns_record" "web_records" {
  count     = "${var.node_count["web"]}"
  cis_id    = "${data.ibm_cis.cis_instance.id}"
  domain_id = "${data.ibm_cis_domain.cis_instance_domain.id}"
  name      = "web${count.index+1}.ans"
  content   = "${element(ibm_compute_vm_instance.web_nodes.*.ipv4_address_private,count.index)}"
  type      = "A"
}


data "template_file" "haproxy_template" {
  depends_on = ["local_file.ansible_hosts"]
  template = "${file("${path.cwd}/Templates/haproxy.tpl")}"
  vars = {
    haproxy_floating_ip = "${cidrhost(ibm_subnet.floating_ip_subnet.subnet_cidr,2)}"
    web1_ip = "${ibm_compute_vm_instance.web_nodes.0.ipv4_address_private}"
    web2_ip = "${ibm_compute_vm_instance.web_nodes.1.ipv4_address_private}"
    web3_ip = "${ibm_compute_vm_instance.web_nodes.2.ipv4_address_private}"
    web4_ip = "${ibm_compute_vm_instance.web_nodes.3.ipv4_address_private}"
  }
}

resource "local_file" "haproxy_template_rendered" {
  content = <<EOF
${data.template_file.haproxy_template.rendered}
EOF

  filename = "${path.cwd}/Files/haproxy.cfg"
}

data "template_file" "haproxy_config_template" {
  depends_on = ["local_file.ansible_hosts"]
  template = "${file("${path.cwd}/Templates/haproxy_config.tpl")}"
  vars = {
    haproxy_floating_ip = "${cidrhost(ibm_subnet.floating_ip_subnet.subnet_cidr,2)}"
    haproxy_floating_ip_netmask = "${cidrhost(ibm_subnet.floating_ip_subnet.subnet_cidr,1)}"
    haproxy_floating_ip_ip_gateway = "${cidrnetmask(ibm_subnet.floating_ip_subnet.subnet_cidr)}"
  }
}

resource "local_file" "haproxy_config_template_rendered" {
  content = <<EOF
${data.template_file.haproxy_config_template.rendered}
EOF

  filename = "${path.cwd}/Ansible/Playbooks/haproxy_config.yml"
}

resource "ibm_cis_dns_record" "floating_ip_record" {
  cis_id    = "${data.ibm_cis.cis_instance.id}"
  domain_id = "${data.ibm_cis_domain.cis_instance_domain.id}"
  name      = "lb"
  content   = "${cidrhost(ibm_subnet.floating_ip_subnet.subnet_cidr,2)}"
  type      = "A"
}

output "FLOATING_IP" {
  value = "${cidrhost(ibm_subnet.floating_ip_subnet.subnet_cidr,2)}"

}

output "LB_URL" {
  value = "${ibm_cis_dns_record.floating_ip_record.name}"
}

output "FLOATING_IP_SUBNET_ID" {
  value = "${ibm_subnet.floating_ip_subnet.id}"
}

resource "null_resource" "call_pushover" {
  
  provisioner "local-exec" {
    command = "/Users/ryan/bin/tf-pusher.sh appnametest"
    interpreter = ["/usr/local/bin/bash", "-c"]
  }
}

data "template_file" "pushover_template" {
  depends_on = ["ibm_cis_dns_record.floating_ip_record"]
  template = "${file("${path.cwd}/Templates/pushover.tpl")}"
  vars = {
    app_name = "${local.workspace["app"]}"
    notes = "This is really just to test if this thing actually works"
  }
}

resource "local_file" "pushover_template_rendered" {
  content = <<EOF
${data.template_file.pushover_template.rendered}
EOF

  filename = "${path.cwd}/push.sh"
}

resource "null_resource" "set_perms" {
  depends_on = ["local_file.pushover_template_rendered"]
  provisioner "local-exec" {
    command = "chmod +x ${path.cwd}/push.sh"
  }
}

resource "null_resource" "push_message" {
  depends_on = ["null_resource.set_perms"]
  provisioner "local-exec" {
    command = "/usr/local/bin/bash ${path.cwd}/push.sh"
  }
}