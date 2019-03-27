resource "null_resource" "haproxy_config_playbook" {
    provisioner "local-exec"  {
        command = "/usr/local/bin/ansible-playbook -i inventory.env Playbooks/haproxy_config.yml"
    }
}

resource "null_resource" "web_config_playbook" {
  provisioner "local-exec" {
    command = "/usr/local/bin/ansible-playbook -i inventory.env Playbooks/web_config.yml"
  }
}

