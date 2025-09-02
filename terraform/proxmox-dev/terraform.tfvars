# Non-sensitive variables only
proxmox_node = "ms1"
ssh_public_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAvvfWM7tH++ShdfZUa6AKYQ/C1XXbfymvnGy3KRy1k3eZpQRhctPRAz9G+LUzjWSunLsAi+ACVWwrXgqqA6k5/MappQLSOWDTxH+QUimEZU2FsZCwHv1ngbSRpl9jpT+PTKrTbKK5QW2l0HcdZb0uGCaXkniaOvdDWNo7K+eF2WxOIxn5KTcM7sgnCby9l0ZqRFOYe3Pe272xGa08ueaFN/vaFSjPmwhdKuYdYZkbCgverGise+AlTKzphyYxXCHynbRg78nMSVLMWDiEtmZAiFey/4uDjNB8vWWi+7Gkyh06uonZ2Ax6sdHOMkZee489pKdKSXdX/EeHRa3QGbdn2mEP3W8haYOhq8kuPVEip5VF08Zi/5uu2kR2gYsoPl4wyhlKuPmJT1jDpIZooi56hHsZCGQB/OWzKkw0pgzLFyexIv2KnIGhBeL8fl7CAySH2Kw28ba8ReWdOU/mVNbuQbWdQmLP88+lMYPeayOE9GTdGqrfaAeGaL9ngGHh3Os= gfm@MBa.gfm"
]

# Advanced mode configuration
# If the below is defined, advanced mode will be used and container_count in variables.tf "simple mode" will be ignored.
containers = [
  # 2 Ubuntu LXCs
  {
    os_type = "ubuntu-25.04"
    hostname = "ubuntu-primary"
    cores = 2
    memory = 2048
  },
  {
    os_type = "ubuntu-25.04"
    cores = 2
    memory = 2048
  },
  
  # 1 AlmaLinux LXC
  {
    os_type = "almalinux-9"
    hostname = "almalinux-server"
    cores = 2
    memory = 4096
  },
  
  # 1 Fedora LXC
  {
    os_type = "fedora-42"
    hostname = "fedora-workstation"
    cores = 1
    memory = 512
  },
  
  # 1 Rocky Linux LXC
  {
    os_type = "rockylinux-9"
    hostname = "rocky-server"
    cores = 2
    memory = 2048
  }
]
# Note: Sensitive variables (proxmox_endpoint, proxmox_api_token_*)
# are provided via environment variables loaded by run-terraform.sh
