terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.83.0"
    }
  }
}

provider "proxmox" {
  alias     = "root"
  endpoint  = var.proxmox_endpoint
  username  = "root@pam"
  password  = var.proxmox_root_password
  insecure  = true
}