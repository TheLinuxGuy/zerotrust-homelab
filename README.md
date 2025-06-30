# zerotrust-homelab
Playground for self-hosting several VPS nodes from multiple clouds in a mesh network. Hosting services like graylog2, wazuh and others.

### Documentation
* [Sauron](./sauron/README.md)
* [Authentik on Sauron](./sauron/authentik/README.md)
* [Uptime Kuma on Sauron](./sauron/uptimekuma/README.md)
* [Hodor](./hodor/README.md)
* [Reverse Proxy & WAF on Hodor](./hodor/reverse-proxy-waf/README.md)

### Nodes
#### Sauron (master overseer)

#nerdhumor: "one node to run them all and in the mesh bind them"

VM hosted in Azure cloud whose sole purpose is to manage and monitor all of the other VPS or remote networks (either public or VPN mesh nodes)

Software stack (all docker):
1. [Komodo](https://komo.do/docs/intro)
2. [Uptime Kuma](https://github.com/louislam/uptime-kuma) (ping monitoring, etc)
3. [Beszel](https://github.com/henrygd/beszel) 

#### Hodor (gatekeeper)
#nerdhumor: "Hold the door!"

An internet exposed VPS that will be permitted to expose certain internal (in.mesh) services to the internet.

##### Komodo setup notes

1. Make sure git is installed `apt-get install git` this is needed to sync with github repos.
