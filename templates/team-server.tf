resource "linode_instance" "team-server" {
    label = "team-server"
    image = "linode/ubuntu23.10"
    region = "nl-ams"
    type = "g6-nanode-1"
    authorized_keys = [linode_sshkey.ssh_key.ssh_key]
    root_pass = random_string.random.result

    swap_size = 256
    private_ip = false

    depends_on = [linode_instance.lighthouse,linode_instance.edge-redirector-1]

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
        source = "configs/nebula/config-teamserver.yaml"
        destination = "/tmp/config.yaml"
    }

    provisioner "file" {
        source = "certificates/ca.crt"
        destination = "/tmp/ca.crt"
    }

    provisioner "file" {
        source = "certificates/team-server.crt"
        destination = "/tmp/host.crt"
    }

    provisioner "file" {
        source = "certificates/team-server.key"
        destination = "/tmp/host.key"
    }

    provisioner "file" {
        source = "C:/dev/C2Spawn/.venv/Scripts/nebula-lin/nebula"
        destination = "/tmp/nebula"
    }

    provisioner "file" {
        source = "files/cobaltstrike.zip"
        destination = "/tmp/cobaltstrike.zip"
    }

    provisioner "file" {
        source = "files/webbug_getonly.profile"
        destination = "/tmp/webbug_getonly.profile"
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
      "apt install unzip -y",
      "apt install openjdk-17-jre -y",
      "apt install openjdk-17-jre -y", # short-cut to set as default
      "ufw allow 22",
      "ufw allow 4242/udp",
      "ufw allow from 192.168.100.110",
      "ufw allow from 192.168.100.120",
      "ufw allow from 192.168.100.250",
      "cat /tmp/key.pub >> /root/.ssh/authorized_keys",
      "chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys",
      "rm /tmp/key.pub",
      "mkdir /etc/nebula",
      "mv /tmp/host.* /etc/nebula",
      "mv /tmp/ca.crt /etc/nebula",
      "mv /tmp/config.yaml /etc/nebula",
      "mv /tmp/nebula /etc/nebula/nebula",
      "mv /tmp/cobaltstrike.zip .",
      "unzip cobaltstrike.zip -d /opt",
      "mv /tmp/webbug_getonly.profile /opt/cobaltstrike/",
      "echo '${tls_private_key.temp_key.private_key_openssh}' > /root/temp_key",
      "chmod 600 /root/temp_key",
      "systemctl disable systemd-resolved.service",
      "systemctl stop systemd-resolved",
      "rm -f /etc/resolv.conf",
      "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf",
      "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf",
      "sed -i 's/LIGHTHOUSE_IP_ADDRESS/${linode_instance.lighthouse.ip_address}/g' /etc/nebula/config.yaml",
      "chmod +x /etc/nebula/nebula",
      "echo '/etc/nebula/nebula -config /etc/nebula/config.yaml' | at now + 1 min",
      "chmod +x -R /opt/cobaltstrike/",
      //Certificate from letsencrypt is sometimes slow to arrive, we need to add delay in the following instructions
      "echo 'scp -oStrictHostKeyChecking=no -i /root/temp_key root@${linode_instance.edge-redirector-1.ip_address}:/root/.local/share/caddy/certificates/acme-staging-v02.api.letsencrypt.org-directory/${var.linode_domain}/* .' | at now + 2 min",
      "echo 'openssl pkcs12 -inkey ${var.linode_domain}.key -in ${var.linode_domain}.crt -export -out acme.pkcs12 -passout pass:123456'| at now + 3 min",
      "echo 'keytool -noprompt -importkeystore -srckeystore acme.pkcs12 -srcstoretype pkcs12 -destkeystore acme.store -deststorepass 123456 -destkeypass 123456 -srcstorepass 123456'| at now + 4 min",
      "echo 'cp acme.store /opt/cobaltstrike/'| at now + 5 min",
      "echo 'cd /opt/cobaltstrike/ && ./teamserver 192.168.100.200 password! webbug_getonly.profile' | at now + 6 min",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}