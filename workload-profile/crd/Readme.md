# crd

## How to configure a custom Workload Profile
- Documentation: https://developer.humanitec.com/integration-and-extensions/workload-profiles/overview/
- Install the CRD definition `kubectl apply -f crd/crd.yaml`. This will create a dummy CRD for this example under the apiVersion `humanitec.com/v1alpha1`
- Start with a default module (Humanitec Provided), see commit https://github.com/Humanitec-DemoOrg/aws-examples/commit/83c05332c072a86d20c5a9bad009528fecd32888
- Update `Chart.yaml` with the new custom profile name and version, along with the required changes, see commit https://github.com/Humanitec-DemoOrg/aws-examples/commit/a252c1e58ef4487bdf22a7b4f19cdc41e4eee131
- The following arguments will be in use:
    - Chart name: mycrdmodule
    - Version: 1.0.0
    - Chart folder: default-module
- Upload the chart (Mac commands, adjust accorgingly), this will create a file called `mycrdmodule-1.0.0.tgz`
```
export HUMANITEC_ORG=myorg
export HUMANITEC_TOKEN=mytoken

export WORKLOAD_PROFILE=mycrdmodule
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
{"created_at":"...","created_by":"...","id":"mycrdmodule","org_id":"myorg","version":"1.0.0"}
```

- Define the Workload Profile
```
export SPEC_DEFINITION=`cat $PROFILE_PATH/profile.json | jq .spec_definition`

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
{{..."title":"mycrdmodule","type":"object"},"updated_at":"...","updated_by":"...","version":"1.0.0","workload_profile_chart":{"id":"mycrdmodule","version":"1.0.0"}}
```

- Deploy an application using Score

Note `score/extension.yaml` line 3 `profile: "myorg/mycrdmodule"` - adjust accordingly with your organization name and profile name.

Create an application called `app`, configure the namespace properly with a resource definition, run:

`score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app app --env development -f score/score.yaml --extensions score/extension.yaml --deploy`

- Inspect your application
```
kube describe mycrd -n app
Name:         backend
Namespace:    app
Labels:       app.kubernetes.io/managed-by=Helm
Annotations:  meta.helm.sh/release-name: backend
              meta.helm.sh/release-namespace: app
API Version:  humanitec.com/v1alpha1
Kind:         MyCRD
Metadata:
  Creation Timestamp:  2023-12-08T21:36:39Z
  Generation:          1
  Resource Version:    113386657
  UID:                 8486fa5d-7a1a-4b2b-bc39-4995bc8aa523
Spec:
  Custom Field:  mycustomvalue
Events:          <none>
  ```
