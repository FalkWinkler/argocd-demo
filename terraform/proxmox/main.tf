terraform {
  required_version = ">= 0.13.0"
  required_providers {   
     sops = {
      source = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "token_secrets" {
  source_file = "token.sops.yaml"
}

# Handles creating the VMs in Proxmox for a Talos Cluster.
# Does NOT bootstrap the cluster.
module "talos" {
    source = "./talos"
    proxmox_host_node = var.proxmox_host_node
    proxmox_api_url = var.proxmox_api_url
    proxmox_api_token_id = data.sops_file.token_secrets.data["proxmox_api_token_id"] #var.proxmox_api_token_id
    proxmox_api_token_secret = data.sops_file.token_secrets.data["proxmox_api_token_secret"] #var.proxmox_api_token_secret
    worker_node_count = 2
    ceph_mon_disk_storage_pool = "Intel_NVME"
}

output "control_plane_mac_addrs" {
    value = module.talos.control_plane_config_mac_addrs
}

output "worker_mac_addrs" {
    value = module.talos.worker_node_config_mac_addrs
}