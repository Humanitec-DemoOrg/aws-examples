# humanitec-firewall-access

## Humanitec IPs
Humanitec might need to access your infrastructure from the following IP addresess: [https://docs.humanitec.com/getting-started/technical-requirements#allow-humanitec-source-ips](https://docs.humanitec.com/getting-started/technical-requirements#allow-humanitec-source-ips)

Humanitec communicates mostly over HTTPS/443/TCP, in some cases it might communicate over SSH/22/TCP (for instance, when accessing your GitHub or GitLab on prem over SSH to clone a repository)

## Humanitec on prem
Outbound access:
  - agent.humanitec.io: SSH 22 TCP
  - logs.humanitec.io HTTPS 443 TCP

## Humanitec agent for private-only AWS EKS clusters
Humanitec can be configured within your cluster using an agent, it communicates with our platform over SSH/22/TCP, to configure please provide a public key per cluster, and Humanitec will provide a Kubernetes manifest and instructions how to configure your cluster.

```
ssh-keygen -t ed25519 -f key_file_name -C "company-environment-teamp"
```
