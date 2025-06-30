# Hodor

Purpose: primary external reverse proxy for external exposed services. Using the following safeguards crowdsec, open-apsec WAF and send all logs to wazuh.

Mesh URL: http://gw.in.mesh

### Known issues or caveats

- Komodo is not able to restrict API communications to a given CIDR range, only explicit IPs. https://github.com/moghtech/komodo/issues/631
    *   Workaround: strict `ufw` firewall rules should ensure any traffic not coming from Mesh VPN interface is blocked.

### Application ports

#### Komodo Periphery (agent API)

- 8120

### Deployment notes

`/mnt/dietpi_userdata/compose/komodo# docker compose --env-file compose.env up -d`

Netbird magic DNS resolution did not work out of the box. Debug via `resolvectl status wt0`.

Had to install some additional software below.
- `apt-get install systemd-resolved dbus`
- `systemctl enable dbus`
- `systemctl start dbus`
- `systemctl enable systemd-resolved.service --now`

#### Komodo agent API

1. Install `curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py | python3`
2. Modify `/etc/komodo/periphery.config.toml`
3. Restart services
4. Add master server to Komodo UI with the internal mesh address. http://gw.in.mesh:8120 

```
systemctl status periphery.service
systemctl restart periphery.service
```

#### Firewall setup allowing mesh VPN only

```shell
# 1. Install and reset UFW to a clean state
sudo apt update
sudo apt install ufw -y
sudo ufw reset

# 2. Ensure IPv6 support is enabled
sudo sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw

# 3. Set default policies (block all incoming on eth0, allow all outgoing)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 4. Allow unrestricted traffic over the WireGuard admin interface (wt0)
sudo ufw allow in on wt0 from any to any
sudo ufw allow out on wt0 from any to any

# 5. Permit only your management IPs on the public interface (eth0)
sudo ufw allow in on eth0 from X to any
sudo ufw allow in on eth0 from Y::48 to any

# 6. Allow reverse proxy ports to the public.
sudo ufw allow in on eth0 to any port 80 proto tcp
sudo ufw allow in on eth0 to any port 443 proto tcp

# 7. Enable UFW (your existing SSH session will remain active)
sudo ufw enable

# 8. Verify rules and status
sudo ufw status verbose
```