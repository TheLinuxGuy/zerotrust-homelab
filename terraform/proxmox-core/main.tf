# Terraform to configure Proxmox VE core system settings (experimental)
# These resources require root@pam privileges

resource "proxmox_virtual_environment_acme_account" "default" {
  provider = proxmox.root
  name     = "default"
  contact  = var.acme_account_email
  directory = "https://acme-v02.api.letsencrypt.org/directory"
  #directory = "https://acme-staging-v02.api.letsencrypt.org/directory" # Use staging for testing; switch to production for real use
  tos       = "https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf"
}

resource "proxmox_virtual_environment_acme_dns_plugin" "default" {
  provider = proxmox.root
  plugin   = "cloudflaredns"
  api = "cf"
  data     = {
    "CF_Account_ID" = var.acme_account_email
    "CF_Token" = var.cloudflare_api_token
    "CF_Zone_ID" = var.cloudflare_zone_id
  }
  depends_on = [
    proxmox_virtual_environment_acme_account.default
  ]
}