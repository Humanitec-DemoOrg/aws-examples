# humanitec-firewall-access

## Humanitec IPs
Humanitec might need to access your infrastructure from the following IP addresess: [https://docs.humanitec.com/getting-started/technical-requirements#allow-humanitec-source-ips](https://docs.humanitec.com/getting-started/technical-requirements#allow-humanitec-source-ips)

Humanitec communicates mostly over HTTPS/443/TCP, in some cases it might communicate over SSH/22/TCP (for instance, when accessing your GitHub or GitLab on prem over SSH to clone a repository)

## Humanitec Outbound access (static IPs):
  - agent.humanitec.io: SSH   22  TCP 34.159.99.194
  - logs.humanitec.io   HTTPS 443 TCP 34.102.177.245

## Humanitec agent for private-only Amazon EKS clusters
Humanitec can be configured within your cluster using an agent, it communicates with our platform over SSH/22/TCP, to configure please provide a public key per cluster, and Humanitec will provide a Kubernetes manifest and instructions how to configure your cluster. Do not set a passphrase.

```
ssh-keygen -t ed25519 -f key_file_name -C "company-environment-team" -N ""
```

### Encoding your private key
Make sure you don't lose the file ending, and it is encoded in one line.
```
cat key_file_name | base64 -w 0 > private-encoded.txt
```

## Verify connectivity
```
kubectl run humanitec-agent --rm -i --tty -n humanitec-agent --image ubuntu -- bash
```
Install the following packages:
```
apt-get update && apt-get install ssh netcat iputils-ping
```
Run the following commands and verify the expected output, if you get timeout or no output, chances are there's a networking issue
```
root@my-shell:/# ssh agent@agent.humanitec.io
...
agent@agent.humanitec.io: Permission denied (publickey).

root@my-shell:/# nc agent.humanitec.io 22
SSH-2.0-OpenSSH_9.1
^C
root@my-shell:/# ping agent.humanitec.io -c 4
....
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
```

## Verify Logs
Upon installing your agent, please verify logs, this will indicate if there's an issue with your key or port. Below is an example of a properly running agent:
```
kubectl get pods -n humanitec-agent

NAME                               READY   STATUS    RESTARTS   AGE
humanitec-agent-5b5d6f4f58-t2lpq   1/1     Running   0          36s
```

```
kube logs humanitec-agent-5b5d6f4f58-t2lpq  -n humanitec-agent

DEBUG     May 18 16:55:43.053 [10]: sending stored logs
NOTICE    May 18 16:55:43.053 [10]: Initializing tinyproxy ...
NOTICE    May 18 16:55:43.053 [10]: Reloading config file
NOTICE    May 18 16:55:43.053 [10]: Reloading config file finished
DEBUG     May 18 16:55:43.053 [10]: done sending stored logs
```
