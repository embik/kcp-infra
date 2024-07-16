resource "oci_core_vcn" "prow" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.oci_compartment_ocid
  display_name   = "Prow Network"
}

resource "oci_core_internet_gateway" "prow" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "Prow Internet Gateway"
  vcn_id         = oci_core_vcn.prow.id
}

resource "oci_core_route_table" "prow_worker" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.prow.id
  display_name   = "Prow Worker Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.prow.id
  }
}

resource "oci_core_subnet" "prow_worker_nodes" {
  availability_domain = null
  cidr_block          = "10.0.64.0/18"
  compartment_id      = var.oci_compartment_ocid
  vcn_id              = oci_core_vcn.prow.id

  security_list_ids = [oci_core_vcn.prow.default_security_list_id]
  route_table_id    = oci_core_route_table.prow_worker.id
  display_name      = "Prow Nodes/Pods Subnet"
}

resource "oci_core_subnet" "prow_worker_cluster" {
  availability_domain = null
  cidr_block          = "10.0.10.0/24"
  compartment_id      = var.oci_compartment_ocid
  vcn_id              = oci_core_vcn.prow.id

  security_list_ids = [oci_core_vcn.prow.default_security_list_id]
  route_table_id    = oci_core_route_table.prow_worker.id
  dhcp_options_id   = oci_core_vcn.prow.default_dhcp_options_id
  display_name      = "Prow Cluster Subnet"
}
