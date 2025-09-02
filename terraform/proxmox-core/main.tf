# Terraform to configure Proxmox VE core system settings (experimental)
# These resources require root@pam privileges

resource "proxmox_virtual_environment_acme_account" "default" {
  provider = proxmox.root
  name     = "default"
  contact  = var.acme_account_email
  # directory = "https://acme-v02.api.letsencrypt.org/directory"
  directory = "https://acme-staging-v02.api.letsencrypt.org/directory" # Use staging for testing; switch to production for real use
  tos       = "https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf"
}

resource "proxmox_virtual_environment_acme_dns_plugin" "cloudflare" {
  provider = proxmox.root
  plugin   = "cloudflare"
  api = "cf"
  data     = {
    CF_TOKEN = var.cloudflare_api_token,
    CF_ACCOUNT_ID = var.acme_account_email
  }

  depends_on = [
    proxmox_virtual_environment_acme_account.default
  ]
}