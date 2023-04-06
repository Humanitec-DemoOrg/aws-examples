# service-account

To attach a Service Account, you must know the workload name and configure the criteria accordingly as `modules.my-workload-name`.

The `workload` resource calls the `k8s-service-account` to retrieve the name.

```
terraform init && terraform apply

score-humanitec delta --api-url https://api.humanitec.io --token ${HUMANITEC_TOKEN} --org ${HUMANITEC_ORG} --app mysaapp --env development -f score.yaml --deploy
```
