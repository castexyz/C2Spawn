resource "linode_domain" "c2-domain" {
    type = "master"
    domain = var.linode_domain
    soa_email = "soa@${var.linode_domain}"
    tags = []

    depends_on = [linode_instance.edge-redirector-1]
}

resource "linode_domain_record" "root" {
    domain_id = linode_domain.c2-domain.id
    name = var.linode_domain
    record_type = "A"
    target = linode_instance.edge-redirector-1.ip_address

    depends_on = [linode_instance.edge-redirector-1]
}