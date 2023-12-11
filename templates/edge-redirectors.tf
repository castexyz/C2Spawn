# HTTPS Dedicated Redirector
resource "linode_instance" "edge-redirector-1" {
    label = "edge-redirector-1"
    image = "linode/ubuntu23.10"
    region = "nl-ams"
    type = "g6-nanode-1"
    authorized_keys = [linode_sshkey.ssh_key.ssh_key]
    root_pass = "Di0Porcone!"

    swap_size = 256
    private_ip = false

    depends_on = [linode_instance.lighthouse]

    connection {
        host = self.ip_address
        user = "root"
        type = "ssh"
        private_key = tls_private_key.temp_key.private_key_pem
        timeout = "10m"
    }

   provisioner "file" {
        source = "keys/red_nebula_rsa.pub"
        destination = "/tmp/key.pub"
    }

    provisioner "file" {
        source = "configs/nebula/config-edge.yaml"
        destination = "/tmp/config.yaml"
    }

    provisioner "file" {
        source = "certificates/ca.crt"
        destination = "/tmp/ca.crt"
    }

    provisioner "file" {
        source = "certificates/edge-redirector-1.crt"
        destination = "/tmp/host.crt"
    }

    provisioner "file" {
        source = "certificates/edge-redirector-1.key"
        destination = "/tmp/host.key"
    }

    provisioner "file" {
        source = "C:/dev/C2Spawn/.venv/Scripts/nebula-lin/nebula"
        destination = "/tmp/nebula"
    }

    provisioner "file" {
        source = "configs/web/Caddyfile.txt"
        destination = "/tmp/Caddyfile"
    }

    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/local/bin",
      "export DEBIAN_FRONTEND=noninteractive",
      //We need to wait for the machine to be fully provisioned before running apt
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "apt update",
      "apt install at -y",
      //"yes | apt upgrade",
      "ufw allow 22",
      "ufw allow 80",
      "ufw allow 443",
      "ufw allow 4242/udp",
      "ufw allow from 192.168.100.110",
      "cat /tmp/key.pub >> /root/.ssh/authorized_keys",
      "rm /tmp/key.pub",
      "mkdir /etc/nebula",
      "mv /tmp/host.* /etc/nebula",
      "mv /tmp/ca.crt /etc/nebula",
      "mv /tmp/config.yaml /etc/nebula",
      "mv /tmp/nebula /etc/nebula/nebula",
      "wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.tar.gz",
      "tar -C /usr/local/bin -xzf caddy_2.7.6_linux_amd64.tar.gz",
      "chmod +x /usr/local/bin/caddy",
      "mv /tmp/Caddyfile .",
      "sed -i 's/EDGE_DOMAIN_NAME/${var.linode_domain}/g' Caddyfile",
      "echo 'cd /root && caddy run --watch' | at now +1 min",
      "sed -i 's/LIGHTHOUSE_IP_ADDRESS/${linode_instance.lighthouse.ip_address}/g' /etc/nebula/config.yaml",
      "chmod +x /etc/nebula/nebula",
      "echo '/etc/nebula/nebula -config /etc/nebula/config.yaml' | at now +1 min",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}