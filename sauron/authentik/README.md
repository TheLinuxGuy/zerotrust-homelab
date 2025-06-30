# Authentik operational playbook

## Internal access from admin VPN

- http://nexus.in.mesh:9000/
- https://nexus.in.mesh:9443/

### Post-install notes

1. You need to create a `failed login` policy to ban IPs with more than X failed login attempts. (Admin -> Customization -> Policies page)
2. Add CAPTCHA protection to login pages to deter bots. You need to modify the default-login flow and add a step between Username and password items (priority 15).
3. Enable MFA.
