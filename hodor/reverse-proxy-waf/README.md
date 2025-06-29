# Stack: Web Application Firewall + Reverse Proxy

An internet exposed VPS that will be permitted to expose certain internal (in.mesh) services to the internet.

Stack:
- Web application firewall: https://www.openappsec.io/
- CrowdSec firewall bouncer: https://crowdsec.io/
- Maxmind IP Geolocation blocking
- NGINX NPMPlus
- Caddy to force and redirect all HTTP to HTTPS

### Implementation notes

This repository will save a `snapshot` of the compose.yaml that was used during initial setup, so `diff` can be used in future NPMPlus releases to easily and quickly see which new environment variables or options may have changed.

**Komodo will save our secrets and environment variables** and pass them directly when starting the stack. The compose.yaml synced by komodo won't contain any of the secrets that are managed in komodo and this intentional and by design. 
* Harmless enviroment variables (non-secrets) will be synced to this public repository by komodo.


`mkdir -p /opt/npmplus/ /opt/npmplus/goaccess/geoip`