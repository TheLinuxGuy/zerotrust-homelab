output "container_ids" {
  description = "VM IDs of the created LXC containers"
  value       = [for container in proxmox_virtual_environment_container.containers : container.vm_id]
}

output "container_hostnames" {
  description = "Hostnames of the created LXC containers"
  value       = [for container in proxmox_virtual_environment_container.containers : container.initialization[0].hostname]
}

output "container_os_types" {
  description = "Operating system types of the created containers"
  value       = [for container in proxmox_virtual_environment_container.containers : container.operating_system[0].type]
}

output "next_available_vm_id" {
  description = "Next available VM ID after the created containers"
  value       = local.base_vm_id + length(local.containers_with_hostnames)
}

output "container_passwords" {
  description = "Generated root passwords for each container"
  value       = [for pwd in random_password.container_passwords : pwd.result]
  sensitive   = true
}

output "container_credentials" {
  description = "Container access information (hostname, VM ID, OS type, and password)"
  value = [
    for idx, container in local.containers_with_hostnames : {
      hostname = container.hostname
      vm_id    = local.base_vm_id + idx
      os_type  = container.os_type
      password = random_password.container_passwords[idx].result
    }
  ]
  sensitive = true
}

output "container_details" {
  description = "Detailed information about each container"
  value = [
    for idx, container in local.containers_with_hostnames : {
      hostname     = container.hostname
      vm_id        = local.base_vm_id + idx
      os_type      = container.os_type
      cores        = container.cores
      memory       = container.memory
      disk_size    = container.disk_size
      ipv4_address = container.ipv4_address
      ipv6_address = container.ipv6_address
      vlan_tag     = container.vlan_tag
    }
  ]
}
