output "lighthouse" {
  value = linode_instance.lighthouse.ip_address
}

output "edge-redirector-1" {
  value = linode_instance.edge-redirector-1.ip_address
}

output "internal-redirector-1" {
  value = linode_instance.internal-redirector-1.ip_address
}

output "team-server" {
  value = linode_instance.team-server.ip_address
}
/*
output "team-server-pass" {
  value = nonsensitive(linode_instance.team-server.root_pass)
}

output "team-server-privkey" {
  value = nonsensitive(tls_private_key.temp_key.private_key_openssh)
}
*/