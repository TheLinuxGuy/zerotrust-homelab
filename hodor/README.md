# Hodor

Purpose: primary external reverse proxy for external exposed services. Using the following safeguards crowdsec, open-apsec WAF and send all logs to wazuh.

Mesh URL: http://gw.in.mesh

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

