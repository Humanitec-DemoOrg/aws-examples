# score-merge
## How to merge multiple workloads

The following approach will allow to merge multiple `score` files and perform one deployment.

*When to use*: Use this when you need to add/remove or modify infrastructure or add/remove variables. If you only require to swap with new image versions, please follow [automation-howto](../automation-howto).

### Merge workflow diagram
![Merge Workflow](images/merge-workflow.png)

### Steps
- Push all your files to a central queue or repository
    - On a new pipeline, process the queue, configure the intervals as needed
- Generate a `delta` for the first workload (any workload can be used as the first workload)
    - Obtain a `delta id`
- Merge workload 2 to the existing delta
    - Merge all the workloads
- Deploy the merged `delta id`

#### Example

##### Setup base variables
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export APP_NAME="myapp"
export APP_ENV="development" #environment name, not environment type
```
#### Create the initial delta
```
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env $APP_ENV -f multiple-workloads-frontend.yaml
```
From the response, export the `delta id`:
```
{
  "id": "4a6330d1c4df6aff308bc510494934eed9634168",
  "metadata": {
  },
  "modules": {
  }
}
```
#### For each subsequent workload, merge sequentially with the `--delta` flag
```
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $APP_NAME --env $APP_ENV -f multiple-workloads-backend.yaml --delta 4a6330d1c4df6aff308bc510494934eed9634168
```
#### Once finalized, deploy
Please note the `delta id` is consistent across each merge call.

Below is an API call example. `humctl` can also be used:

```
export DELTA_ID="4a6330d1c4df6aff308bc510494934eed9634168"
curl -s -X \
POST -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
 -H \
 "Content-type: application/json" -d '{
"comment": "",
"delta_id": "'"${DELTA_ID}"'"
}' "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${APP_NAME}/envs/${APP_ENV}/deploys"

```

Example response:

```
{
   "set_id":"f7c_5FOQsVtuq-XKVpukW0uy5K44VP8Z_0OreP3Udwk",
   "delta_id":"4a6330d1c4df6aff308bc510494934eed9634168",
   "comment":"",
   "id":"17609cfafa5d5cb8",
   "env_id":"",
   "created_at":"2023-05-19T17:54:22.392745144Z",
   "created_by":"s-9dd08936-f72f-42da-a875-69f089d44df8",
   "status":"in progress",
   "status_changed_at":"2023-05-19T17:54:22.392745144Z",
   "from_id":"",
   "export_status":"",
   "export_file":""
}
```
