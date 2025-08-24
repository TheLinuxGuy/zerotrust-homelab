# Stack: Web Application Firewall + Reverse Proxy

An internet exposed VPS that will be permitted to expose certain internal (in.mesh) services to the internet.

Stack:
- Web application firewall: https://www.openappsec.io/
- CrowdSec firewall bouncer: https://crowdsec.io/
- Maxmind IP Geolocation blocking
- NGINX NPMPlus
- Caddy to force and redirect all HTTP to HTTPS

## Operational playbook

### NPM Protecting an application with authentik permissions (Forward Auth) {#fordward-auth}

> [!IMPORTANT]  
> This section only covers NPM and doesn't cover the Authentik web UI side of the configurations that are pre-requisite (`Providers`, `Applications` and end-user permission grants)

1. `modsecurity` must be disabled in NPM web UI for the service.
1. `proxy_pass` string is the internal service URL and port (8080 in the below example)


```bash
# Make sure not to redirect traffic to a port 4443
port_in_redirect off;

location / {
    # Put your proxy_pass to your application here
    proxy_pass          http://nexus.in.mesh:8080;
    # Set any other headers your application might need
    # Preserve original client IP
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP       $remote_addr;

    ##############################
    # authentik-specific config
    ##############################
    auth_request     /outpost.goauthentik.io/auth/nginx;
    error_page       401 = @goauthentik_proxy_signin;
    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header       Set-Cookie $auth_cookie;

    # translate headers from the outposts back to the actual upstream
    auth_request_set $authentik_username $upstream_http_x_authentik_username;
    auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
    auth_request_set $authentik_entitlements $upstream_http_x_authentik_entitlements;
    auth_request_set $authentik_email $upstream_http_x_authentik_email;
    auth_request_set $authentik_name $upstream_http_x_authentik_name;
    auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

    proxy_set_header X-authentik-username $authentik_username;
    proxy_set_header X-authentik-groups $authentik_groups;
    proxy_set_header X-authentik-entitlements $authentik_entitlements;
    proxy_set_header X-authentik-email $authentik_email;
    proxy_set_header X-authentik-name $authentik_name;
    proxy_set_header X-authentik-uid $authentik_uid;

    # This section should be uncommented when the "Send HTTP Basic authentication" option
    # is enabled in the proxy provider
    # auth_request_set $authentik_auth $upstream_http_authorization;
    # proxy_set_header Authorization $authentik_auth;
}

location /outpost.goauthentik.io {
    proxy_pass http://nexus.in.mesh:9000/outpost.goauthentik.io;
    proxy_set_header Host $host;
    proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
    add_header Set-Cookie $auth_cookie;
    auth_request_set $auth_cookie $upstream_http_set_cookie;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
}

# Special location for when the /auth endpoint returns a 401,
# redirect to the /start URL which initiates SSO
location @goauthentik_proxy_signin {
    internal;
    add_header Set-Cookie $auth_cookie;
    return 302 /outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
    # For domain level, use the below error_page to redirect to your authentik server with the full redirect path
    # return 302 https://authentik.company/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
}
```

### Implementation notes

This repository will save a `snapshot` of the compose.yaml that was used during initial setup, so `diff` can be used in future NPMPlus releases to easily and quickly see which new environment variables or options may have changed.

**Komodo will save our secrets and environment variables** and pass them directly when starting the stack. The compose.yaml synced by komodo won't contain any of the secrets that are managed in komodo and this intentional and by design. 
* Harmless enviroment variables (non-secrets) will be synced to this public repository by komodo.


`mkdir -p /opt/npmplus/ /opt/npmplus/goaccess/geoip`