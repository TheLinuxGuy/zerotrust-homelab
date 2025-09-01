# Data source to get existing VMs for automatic ID generation
data "proxmox_virtual_environment_vms" "existing_vms" {
  node_name = var.proxmox_node
}

# Calculate next available VM ID (starting from 200 to avoid conflicts)
locals {
  existing_vm_ids = [for vm in data.proxmox_virtual_environment_vms.existing_vms.vms : vm.vm_id]
  max_vm_id       = length(local.existing_vm_ids) > 0 ? max(local.existing_vm_ids...) : 99
  base_vm_id      = max(local.max_vm_id + 1, 200)  # Start from 200 to avoid existing containers
}

# Generate random passwords for each container
resource "random_password" "container_passwords" {
  count = var.container_count

  length           = var.password_length
  special          = var.password_special
  override_special = var.password_override_special
  lower            = true
  upper            = true
  numeric          = true
}

# LXC Containers
resource "proxmox_virtual_environment_container" "ubuntu_containers" {
  count = var.container_count

  node_name = var.proxmox_node
  vm_id     = local.base_vm_id + count.index
  unprivileged = true  # Use unprivileged containers to avoid permission issues

  # Operating System
  operating_system {
    type = "ubuntu"
    template_file_id = var.template_name
  }

  # CPU and Memory
  cpu {
    cores = var.container_cores
  }

  memory {
    dedicated = var.container_memory
  }

  # Disk
  disk {
    datastore_id = var.storage_pool
    size         = var.container_disk_size
  }

  # Network - All containers use vmbr0 for now
  # Note: SDN configuration requires manual setup in Proxmox or different provider version
  network_interface {
    name    = "eth0"
    bridge  = var.network_bridge
  }

  # Initialization
  initialization {
    hostname = format("ubuntu-lxc-%02d", count.index + 1)

    user_account {
      password = random_password.container_passwords[count.index].result
      keys     = var.ssh_public_keys
    }
  }

  # Features - Removed privileged features to work with current permissions
  features {
    nesting = true
  }

  # Start on boot
  started = true

  # Tags
  tags = ["terraform", "lxc", "ubuntu"]
}
