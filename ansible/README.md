## Ansible Standalone Playbooks for Homelab (Managed by Semaphore UI)

This folder contains standalone infrastructure-as-code `.yaml` files for Ansible, designed to be managed and executed by [Semaphore UI](https://semaphoreui.com/) in the homelab environment.

### Why Semaphore UI?

[Semaphore UI](https://semaphoreui.com/) is an open-source web interface for Ansible that provides:

- **Centralized Execution:** Run and manage all Ansible playbooks from a single, web-based dashboard.
- **Auditability:** Track who ran what, when, and with which parameters for full traceability and compliance.
- **Scheduling:** Automate playbook runs with built-in scheduling features.
- **Secrets Management:** Securely store and manage secrets, credentials, and environment variables directly in Semaphore UI, keeping sensitive data out of source code.
- **Team Collaboration:** Delegate access and manage permissions for different users and teams.

Semaphore UI abstracts away the need for the traditional Ansible folder structure (such as `roles/`, `inventory/`, etc.), as it manages inventories, credentials, and execution environments internally. This allows us to focus on writing clear, modular, and reusable playbooks.

### Folder Structure

*This folder may not follow the common Ansible best-practice hierarchy*. Instead, you will find standalone `.yaml` playbooks, each representing a specific task or automation. Semaphore UI handles inventory, secrets, and orchestration, so only the playbooks themselves are stored here.