variable "acme_account_email" {
  description = "Email address for the ACME account"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for ACME DNS challenge"
  type        = string
  sensitive   = true
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_root_password" {
  description = "Proxmox root password"
  type        = string
  sensitive   = true
}