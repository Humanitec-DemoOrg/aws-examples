# initcontainer

## How to configure a custom Workload Profile
- Documentation: https://developer.humanitec.com/integration-and-extensions/workload-profiles/overview/
- Sorting: init containers will be sorted by name. Adjust accordingly.
- Start with a default module (Humanitec Provided), see commit [https://github.com/Humanitec-DemoOrg/aws-examples/commit/2fde311147663b8ddf7a6657a5d4ff34d70508e9](https://github.com/Humanitec-DemoOrg/aws-examples/commit/2fde311147663b8ddf7a6657a5d4ff34d70508e9)
- Update `Chart.yaml` with the new custom profile name and version, along with the required changes, see commit [https://github.com/Humanitec-DemoOrg/aws-examples/commit/93cd272c5d339ba764f1e4a136b0454af81c5deb [93cd272]](https://github.com/Humanitec-DemoOrg/aws-examples/commit/012696a410ee0bccad61020640d5a11b57096b70)
- The following arguments will be in use:
    - Chart name: myinitcontainers
    - Version: 1.0.0
    - Chart folder: default-module
- Upload the chart (Mac commands, adjust accorgingly), this will create a file called `myinitcontainers-1.0.0.tgz`
```
export HUMANITEC_ORG=myorg
export HUMANITEC_TOKEN=mytoken

export WORKLOAD_PROFILE=myinitcontainers
export PROFILE_VERSION=1.0.0
export PROFILE_PATH=default-module

tar --disable-copyfile --exclude='.DS_Store' -czf \
    "${WORKLOAD_PROFILE}-${PROFILE_VERSION}.tgz" \
    $PROFILE_PATH

curl -X POST "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/workload-profile-chart-versions" \
  -F "file=@${WORKLOAD_PROFILE}-${PROFILE_VERSION}.tgz" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}"
```
Output

```
{"created_at":"...","created_by":"...","id":"myinitcontainers","org_id":"myorg","version":"1.0.0"}
```

- Define the Workload Profile
```
export SPEC_DEFINITION=`cat $PROFILE_PATHprofile.json | jq .spec_definition`

curl -X POST "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/workload-profiles" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
  --data-binary @- << EOF
{
   "id":"$WORKLOAD_PROFILE",
   "version":"$PROFILE_VERSION",
   "spec_definition": $SPEC_DEFINITION,
   "workload_profile_chart": { "id": "${WORKLOAD_PROFILE}", "version": "${PROFILE_VERSION}" }
}
EOF
```
Output
```
{{..."title":"myinitcontainers","type":"object"},"updated_at":"...","updated_by":"...","version":"1.0.0","workload_profile_chart":{"id":"myinitcontainers","version":"1.0.0"}}
```

- Deploy an application using Score

Note `score/extension.yaml` line 3 `profile: "myorg/myinitcontainers"` - adjust accordingly with your organization name and profile name.

Create an application called `app`, configure the namespace properly with a resource definition, run:

`score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app app --env development -f score/score.yaml --extensions score/extension.yaml --deploy`

- Inspect your application
```
kube describe pods -n app-development
Name:             backend-54b7b5b744-bbgkv
....
Init Containers:
  ubuntu-a:
    Container ID:  containerd://e3322a901bb697bb89399b89b10af480ab2929dad50d594737956324bb6c5030
    Image:         ubuntu:latest
    Image ID:      docker.io/library/ubuntu@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/bash
    Args:
      -c
      echo "******"; exit 0
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Tue, 05 Dec 2023 20:03:54 -0700
      Finished:     Tue, 05 Dec 2023 20:03:54 -0700
    Ready:          True
    Restart Count:  0
...
  ubuntu-b:
    Container ID:  containerd://850ec90f97c0ca6a1c58012ec427ead21be4d20deff7271a3f7c71e4ab08ef35
    Image:         ubuntu:latest
    Image ID:      docker.io/library/ubuntu@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/bash
    Args:
      -c
      echo "******"; exit 0
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Tue, 05 Dec 2023 20:03:55 -0700
      Finished:     Tue, 05 Dec 2023 20:03:55 -0700
    Ready:          True
...
  ubuntu-c:
    Container ID:  containerd://2fd5ea1f51e95537064ea4c124b31715bfabea55fa55ffba5b031d429898d90a
    Image:         ubuntu:latest
    Image ID:      docker.io/library/ubuntu@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/bash
    Args:
      -c
      echo "******"; exit 0
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Tue, 05 Dec 2023 20:03:56 -0700
      Finished:     Tue, 05 Dec 2023 20:03:56 -0700

...
Containers:
  ubuntu:
    Container ID:  containerd://d182b8cbf51e3bb5ba83d556c580e3bf0e134397a2fced054713bfdc864bfec6
    Image:         ubuntu:latest
    Image ID:      docker.io/library/ubuntu@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/bash
    Args:
      -c
      while true; do printenv && echo "****"; sleep 120; done
    State:          Running
      Started:      Tue, 05 Dec 2023 19:22:07 -0700
    Ready:          True
...
  ```
