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

  # Network - DHCP by default with optional static IP support
  # Note: SDN configuration requires manual setup in Proxmox or different provider version
  # VLAN tagging (vlan_tag variable) requires SDN or tagged bridge configuration
  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  # Initialization
  initialization {
    hostname = format("ubuntu-lxc-%02d", count.index + 1)

    ip_config {
      ipv4 {
        address = var.ipv4_address != "" ? var.ipv4_address : "dhcp"
      }
      ipv6 {
        address = var.ipv6_address != "" ? var.ipv6_address : "dhcp"
      }
    }

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

# Display passwords during apply using terraform output
resource "null_resource" "display_passwords" {
  depends_on = [
    random_password.container_passwords,
    proxmox_virtual_environment_container.ubuntu_containers
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo ""
      echo "🔐 GENERATED CONTAINER PASSWORDS:"
      echo "=================================="
      terraform output -json container_credentials | jq -r '.[] | "\(.hostname) (VM ID: \(.vm_id)): \(.password)"'
      echo ""
      echo "💡 SSH Access:"
      echo "=============="
      echo "SSH Key: Already configured for root user"
      echo "Password: Use generated passwords above for fallback"
      echo ""
      echo "📝 To view passwords later:"
      echo "terraform output container_credentials"
      echo ""
    EOT

    environment = {
      TF_DATA_DIR = ".terraform"
    }
  }

  # Trigger re-run when passwords change
  triggers = {
    passwords = join(",", random_password.container_passwords[*].result)
  }
}
