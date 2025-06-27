# zerotrust-homelab
Playground for self-hosting several VPS nodes from multiple clouds in a mesh network. Hosting services like graylog2, wazuh and others.

### Nodes

#### Sauron (master overseer)

Funny tag line: "one node to run them all and in the mesh bind them"

VM hosted in Azure cloud whose sole purpose is to manage and monitor all of the other VPS or remote networks (either public or VPN mesh nodes)

Software stack (all docker):
1. [Komodo](https://komo.do/docs/intro)
2. [Uptime Kuma](https://github.com/louislam/uptime-kuma) (ping monitoring, etc)
3. [Beszel](https://github.com/henrygd/beszel) 


##### Komodo setup notes

1. Make sure git is installed `apt-get install git` this is needed to sync with github repos.