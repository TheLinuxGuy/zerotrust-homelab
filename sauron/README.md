# Sauron

IMPORTANT: This public repository does not expose my .env file. You can get yours [here](https://raw.githubusercontent.com/moghtech/komodo/main/compose/compose.env).

2 core and 4GB ram VPS from Microsoft Azure. Running [DietPi](https://dietpi.com/) low memory footprint and optimized OS. **Important: Microsoft  Azure Linux VMs have a 8gb secondary disk mounted on `/mnt` this data is not safe** - so make sure to reconfigure the `/etc/fstab` to point the 8GB disk to another folder like `/swapfs` then move the `/mnt/dietpi_userdata` folder to the `/dev/sda` disk as this one is guaranteed by Microsoft to keep your data safe.

Primary reason for chosing dietpi other than OS optimizations:
- built-in scheduled backups

Mesh URL: http://nexus.in.mesh

### Application ports

#### Komodo Core

- 9120

http://nexus.in.mesh:9120

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

