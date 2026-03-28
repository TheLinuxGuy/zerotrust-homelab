# Terraform Proxmox LXC Container Setup

This Terraform configuration creates secure LXC containers on Proxmox with support for multiple operating systems, automatic SSH key authentication, random password generation, and comprehensive security features.

## ✨ New Features

- **Multi-OS Support**: Ubuntu, AlmaLinux, Fedora, and Rocky Linux
- **Flexible Configuration**: Simple mode for quick setup or advanced mode for detailed customization
- **Per-Container Customization**: Individual hostnames, resources, network settings, and VLANs
- **Backward Compatibility**: Existing simple configurations continue to work

## 🚀 Features

- **Multi-OS LXC Containers** with automatic VM ID assignment
- **SSH Key Authentication** with provided public keys
- **Secure Random Passwords** (16 characters, displayed during apply)
- **Dual Environment Support** (Local development + Semaphore UI CI/CD)
- **Automatic Resource Management** with Terraform
- **Production-Ready Security** baseline
- **Flexible Configuration** (Simple or Advanced mode)
- **Per-Container Customization** (hostname, resources, network)

## 📋 Prerequisites

- **Terraform** (v1.0+)
- **Proxmox** server access with API token
- **SSH Key Pair** for container access
- **Ansible** (for post-deployment hardening - strongly recommended)

## 🔧 Local Development Setup

### 1. Clone and Navigate
```bash
git clone <repository>
cd terraform/proxmox-dev
```

### 2. Configure Environment Variables
Create `.env` file with your local credentials:
```bash
# terraform/proxmox-dev/.env
export proxmox_endpoint="https://your-proxmox-server:8006/api2/json"
export proxmox_api_token_id="terraform@pam!terraform-token"
export proxmox_api_token_secret="your-api-token-secret"
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan Deployment
```bash
./run-terraform.sh plan
```

### 5. Deploy Containers
```bash
./run-terraform.sh apply
```

### 6. ⚠️ **IMMEDIATELY RUN ANSIBLE HARDENING** ⚠️
**This step is CRITICAL for security!**

After Terraform creates the containers, immediately run the Ansible hardening playbook:

```bash
# Set required environment variables for Ansible
export SYSTEM_USER="your-admin-user"
export USER_SSHKEY="your-user-ssh-public-key"
export USER_PASSWORD="your-user-password"
export SYSTEM_TZ="America/New_York"
export SYSTEM_SSHKEY="your-system-ssh-public-key"
export SEMAPHORE_SSHKEY="semaphore-ssh-public-key"

# Run the hardening playbook
ansible-playbook -i /path/to/inventory ansible/initial-linux-setup-hardening.yml
```

**What the hardening playbook does:**
- ✅ Installs security packages (fail2ban, htop, etc.)
- ✅ Configures fail2ban for SSH protection
- ✅ Creates admin user with SSH key authentication
- ✅ **Disables SSH password authentication globally**
- ✅ Enables SSH key authentication only
- ✅ Sets up system timezone
- ✅ Adds monitoring and security tools

**Without this step, your containers will have password authentication enabled!**

## 🔐 Semaphore UI Integration

### Variable Setup in Semaphore UI

In your Semaphore UI variable group, create these environment variables:

| Semaphore UI Variable | Value |
|----------------------|--------|
| `TF_VAR_proxmox_endpoint` | `https://your-proxmox-server:8006/api2/json` |
| `TF_VAR_proxmox_api_token_id` | `terraform@pam!terraform-token` |
| `TF_VAR_proxmox_api_token_secret` | `your-api-token-secret` |

### Important: TF_VAR_ Prefix Required inside Semaphore UI Variable groups.

**Semaphore UI requires you to prefix `TF_VAR_` to variables if you wish to use them in terraform executions within Semaphore UI.**

This means:
- In Semaphore UI, you define: `proxmox_endpoint`
- Semaphore UI converts it to: `TF_VAR_proxmox_endpoint`
- Terraform reads it as: `var.proxmox_endpoint`

### Pipeline Configuration

Your Semaphore UI pipeline should:
1. Use the same `terraform/proxmox-dev/` directory
2. Run `terraform init`, `terraform plan`, `terraform apply`
3. **Immediately follow with the Ansible hardening playbook**

## 📁 File Structure

```
terraform/proxmox-dev/
├── README.md              # This file
├── providers.tf           # Proxmox provider configuration
├── variables.tf           # Variable declarations
├── terraform.tfvars       # Non-sensitive variable values
├── main.tf               # LXC container resources
├── outputs.tf            # Output definitions
├── run-terraform.sh      # Local development helper script
├── .env                  # Local environment variables (gitignored)
└── .terraform/           # Terraform state (gitignored)
```

## 🔑 Security Features

### SSH Security
- **SSH Key Authentication**: Primary authentication method
- **Random Password Generation**: 16-character secure passwords
- **Password Display**: Shown during `terraform apply` for backup access

### Network Security
- **Isolated Containers**: Each with unique VM ID
- **Bridge Networking**: Connected to vmbr0
- **Firewall Ready**: fail2ban pre-configured via Ansible

### Access Control
- **Root SSH Key Access**: Immediate secure access
- **Admin User Creation**: Via Ansible hardening playbook
- **Password Authentication Disabled**: After Ansible hardening

## 🛠️ Configuration Options

### Container Specifications
- **CPU**: 2 cores per container
- **Memory**: 2048MB per container
- **Disk**: 20GB per container
- **OS**: Ubuntu 25.04
- **Storage**: local-zfs

### Two Configuration Modes

#### Simple Mode (Backward Compatible)
For basic setups with uniform configuration:

```hcl
# terraform.tfvars
container_count = 4
os_type = "ubuntu-25.04"
container_cores = 2
container_memory = 2048
container_disk_size = 20
```

This creates 4 Ubuntu containers with auto-generated hostnames: `ubuntu-25.04-lxc-01`, `ubuntu-25.04-lxc-02`, etc.

#### Advanced Mode (Per-Container Customization)
For detailed, per-container configuration:

```hcl
# terraform.tfvars
containers = [
  {
    os_type = "ubuntu-25.04"
    hostname = "web-server"
    cores = 2
    memory = 2048
    disk_size = 20
    ipv4_address = "192.168.1.10/24"
    vlan_tag = 10
  },
  {
    os_type = "almalinux-9"
    hostname = "db-server"
    cores = 4
    memory = 4096
    disk_size = 50
  },
  {
    os_type = "fedora-42"
    cores = 1
    memory = 1024
  },
  {
    os_type = "rockylinux-9"
    hostname = "monitoring"
    cores = 2
    memory = 2048
    ipv4_address = "192.168.1.15/24"
  }
]
```

**Note**: When `containers` is defined, simple mode variables are ignored.

### Supported Operating Systems
- `ubuntu-25.04`
- `almalinux-9`
- `fedora-42`
- `rockylinux-9`

### Per-Container Options
- `os_type`: Operating system (required)
- `hostname`: Custom hostname (auto-generated if not specified)
- `cores`: CPU cores (default: 2)
- `memory`: Memory in MB (default: 2048)
- `disk_size`: Disk size in GB (default: 20)
- `ipv4_address`: Static IPv4 with CIDR (DHCP if empty)
- `ipv6_address`: Static IPv6 with CIDR (DHCP if empty)
- `vlan_tag`: VLAN tag number (optional)

## 📊 Outputs

After deployment, Terraform provides:
- Container VM IDs
- Container hostnames
- Generated passwords (sensitive - use `terraform output container_credentials`)
- Next available VM ID

## 🚨 Important Security Notes

1. **NEVER commit secrets** to version control
2. **ALWAYS run the Ansible hardening playbook** immediately after Terraform deployment
3. **Store generated passwords securely** (password manager recommended)
4. **Use SSH keys for primary authentication**
5. **Regularly update and patch** your containers

## 🔍 Troubleshooting

### Common Issues

**"Variables not allowed" error:**
- Remove variable references from `terraform.tfvars`
- Use environment variables instead

**SSH connection issues:**
- Verify SSH keys are correctly formatted
- Check network connectivity
- Ensure containers are running

**Semaphore UI issues:**
- Verify TF_VAR_ prefix is correctly applied
- Check variable group permissions
- Confirm API token validity

### Getting Help

1. Check Terraform logs: `terraform plan -debug`
2. Verify environment variables: `env | grep TF_VAR`
3. Test SSH connectivity: `ssh -i ~/.ssh/id_rsa root@container-hostname`

## 📚 Related Documentation

- [Terraform Proxmox Provider](https://registry.terraform.io/providers/bpg/proxmox/latest)
- [Semaphore UI Documentation](https://docs.semaphoreui.com/)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Remember: Security first! Always run the Ansible hardening playbook immediately after Terraform deployment.** 🔒
