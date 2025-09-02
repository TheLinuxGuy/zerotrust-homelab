# Data source to get existing VMs for automatic ID generation
data "proxmox_virtual_environment_vms" "existing_vms" {
  node_name = var.proxmox_node
}

data "proxmox_virtual_environment_containers" "existing_containers" {}

# OS template and type mapping
locals {
  os_templates = {
    "ubuntu-25.04" = "local:vztmpl/ubuntu-25.04-standard_25.04-1.1_amd64.tar.zst"
    "almalinux-9" = "local:vztmpl/almalinux-9-default_20240911_amd64.tar.xz"
    "fedora-42" = "local:vztmpl/fedora-42-default_20250428_amd64.tar.xz"
    "rockylinux-9" = "local:vztmpl/rockylinux-9-default_20240912_amd64.tar.xz"
  }

  # Map OS types to generic OS type for provider
  os_type_mapping = {
    "ubuntu-25.04" = "ubuntu"
    "almalinux-9" = "centos"  # AlmaLinux is RHEL-based like CentOS
    "fedora-42" = "fedora"
    "rockylinux-9" = "centos"  # Rocky Linux identifies itself as CentOS too.
  }

  # Determine configuration mode and create container configurations
  use_advanced_mode = length(var.containers) > 0

  # Simple mode: generate configurations from basic variables
  simple_containers = local.use_advanced_mode ? [] : [
    for i in range(var.container_count) : {
      index        = i
      os_type      = var.os_type
      hostname     = null  # Will be generated
      cores        = var.container_cores
      memory       = var.container_memory
      disk_size    = var.container_disk_size
      ipv4_address = var.ipv4_address
      ipv6_address = var.ipv6_address
      vlan_tag     = var.vlan_tag
    }
  ]

  # Combined container configurations (simple or advanced)
  all_containers = local.use_advanced_mode ? var.containers : local.simple_containers

  # Generate hostnames for containers that don't have one specified
  containers_with_hostnames = [
    for idx, container in local.all_containers : merge(container, {
      hostname = container.hostname != null ? container.hostname : format("%s-lxc-%02d", container.os_type, idx + 1)
      index = idx
    })
  ]

  # Calculate next available VM ID (starting from 200 to avoid conflicts)
  existing_vm_ids = [for vm in data.proxmox_virtual_environment_vms.existing_vms.vms : vm.vm_id]
  existing_container_ids = [for c in data.proxmox_virtual_environment_containers.existing_containers.containers : c.vm_id]
  all_existing_ids = concat(local.existing_vm_ids, local.existing_container_ids)
  max_vm_id       = length(local.all_existing_ids) > 0 ? max(local.all_existing_ids...) : 99
  base_vm_id      = max(local.max_vm_id + 1, 200)  # Start from 200 to avoid existing containers
}

# Generate random passwords for each container
resource "random_password" "container_passwords" {
  for_each = { for idx, container in local.containers_with_hostnames : idx => container }

  length           = var.password_length
  special          = var.password_special
  override_special = var.password_override_special
  lower            = true
  upper            = true
  numeric          = true
}

# LXC Containers
resource "proxmox_virtual_environment_container" "containers" {
  for_each = { for idx, container in local.containers_with_hostnames : idx => container }

  node_name = var.proxmox_node
  vm_id     = local.base_vm_id + each.key
  unprivileged = true  # Use unprivileged containers to avoid permission issues

  # Operating System
  operating_system {
    type = lookup(local.os_type_mapping, each.value.os_type, "ubuntu")
    template_file_id = lookup(local.os_templates, each.value.os_type, local.os_templates["ubuntu-25.04"])
  }

  # CPU and Memory
  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  # Disk
  disk {
    datastore_id = var.storage_pool
    size         = each.value.disk_size
  }

  # Network - DHCP by default with optional static IP support
  # Note: SDN configuration requires manual setup in Proxmox or different provider version
  # VLAN tagging (vlan_tag variable) requires SDN or tagged bridge configuration
  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
    # VLAN support per container
    vlan_id = each.value.vlan_tag != null ? each.value.vlan_tag : null
  }

  # Initialization
  initialization {
    hostname = each.value.hostname

    ip_config {
      ipv4 {
        address = each.value.ipv4_address != "" ? each.value.ipv4_address : "dhcp"
      }
      ipv6 {
        address = each.value.ipv6_address != "" ? each.value.ipv6_address : "dhcp"
      }
    }

    user_account {
      password = random_password.container_passwords[each.key].result
      keys     = var.ssh_public_keys
    }
  }

  # Features - Removed privileged features to work with current permissions
  features {
    nesting = true
  }

  # Start on boot
  started = true

  # Tags - Dynamic based on OS type
  tags = ["terraform", "lxc", each.value.os_type]
}

# Display passwords during apply using terraform output
resource "null_resource" "display_passwords" {
  depends_on = [
    random_password.container_passwords,
    proxmox_virtual_environment_container.containers
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
    passwords = join(",", [for pwd in random_password.container_passwords : pwd.result])
  }
}