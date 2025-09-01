variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "ms1"
}

variable "container_count" {
  description = "Number of LXC containers to create"
  type        = number
  default     = 4
}

variable "container_cores" {
  description = "Number of CPU cores per container"
  type        = number
  default     = 2
}

variable "container_memory" {
  description = "Memory in MB per container"
  type        = number
  default     = 2048
}

variable "container_disk_size" {
  description = "Disk size for containers in GB"
  type        = number
  default     = 20
}

variable "storage_pool" {
  description = "Storage pool for container disks"
  type        = string
  default     = "local-zfs"
}

variable "template_name" {
  description = "LXC template name"
  type        = string
  default     = "local:vztmpl/ubuntu-25.04-standard_25.04-1.1_amd64.tar.zst"
}

variable "network_bridge" {
  description = "Network bridge for containers"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to containers"
  type        = list(string)
  default     = []
}

variable "sdn_zone_name" {
  description = "SDN zone name"
  type        = string
  default     = "homelab-zone"
}

variable "sdn_vnet_name" {
  description = "SDN VNet name"
  type        = string
  default     = "homelab-vnet"
}

variable "sdn_parent_interface" {
  description = "Parent interface for SDN zone"
  type        = string
  default     = "vmbr0"
}

variable "password_length" {
  description = "Length of randomly generated passwords"
  type        = number
  default     = 16
}

variable "password_special" {
  description = "Include special characters in passwords"
  type        = bool
  default     = true
}

variable "password_override_special" {
  description = "Override special characters (e.g., '!@#$%^&*')"
  type        = string
  default     = "!@#$%^&*"
}
