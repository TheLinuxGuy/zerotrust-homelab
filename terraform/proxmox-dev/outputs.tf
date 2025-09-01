output "container_ids" {
  description = "VM IDs of the created LXC containers"
  value       = proxmox_virtual_environment_container.ubuntu_containers[*].vm_id
}

output "container_hostnames" {
  description = "Hostnames of the created LXC containers"
  value       = proxmox_virtual_environment_container.ubuntu_containers[*].initialization[0].hostname
}

output "next_available_vm_id" {
  description = "Next available VM ID after the created containers"
  value       = local.base_vm_id + var.container_count
}

output "container_passwords" {
  description = "Generated root passwords for each container"
  value       = random_password.container_passwords[*].result
  sensitive   = true
}

output "container_credentials" {
  description = "Container access information (hostname, IP if available, and password)"
  value = [
    for i in range(var.container_count) : {
      hostname = format("ubuntu-lxc-%02d", i + 1)
      vm_id    = local.base_vm_id + i
      password = random_password.container_passwords[i].result
    }
  ]
  sensitive = true
}
