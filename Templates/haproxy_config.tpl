---
  - hosts: haproxy
    become: true
    tasks:
      - name: Adding Portable IP to Haproxy nodes
        blockinfile:
          path: /etc/network/interfaces.d/50-cloud-init.cfg
          block: |
            auto eth1:1
            iface eth1:1 inet static
            address ${haproxy_floating_ip}/30
            netmask: ${haproxy_floating_ip_netmask}
            gateway: ${haproxy_floating_ip_ip_gateway}
      - name: Install keepalived
        apt:
          name: keepalived
          state: present
      - name: Config keepalived
        copy:
          dest: /etc/keepalived/keepalived.conf
          content: |
            vrrp_instance VI_1 {
                state MASTER
                interface eth1
                virtual_router_id 51
                priority 101
                advert_int 1
                authentication {
                    auth_type PASS
                    auth_pass 1111
                }
                virtual_ipaddress {
                    ${haproxy_floating_ip}
                }
            }
      - name: Check if default haproxy.cfg exists
        stat:
          path: /etc/haproxy/haproxy.cfg
        register: haproxy_cfg
      - name: Backup original haproxy.cfg on Haproxy hosts
        command: creates="haproxy.cfg" mv /etc/haproxy/haproxy.cfg /root/haproxy.cfg.orig
        when: haproxy_cfg.stat.exists
      - name: Put Terraform generated haproxy.cfg file on Haproxy hosts
        copy:
          src: '../../Files/haproxy.cfg'
          dest: /etc/haproxy/haproxy.cfg
          owner: root
          group: root
          mode: 0644
      - name: Bring up floating IP
        shell: ifup eth1:1
        args:
          executable: /bin/bash
      - name: Restart haproxy
        systemd: 
          name: haproxy
          state: reloaded
          enabled: yes
      - name: Restart keepalived
        systemd: 
          name: keepalived
          state: reloaded
          enabled: yes