# scripts

- Delete a specific workload from an app [delete-workload.sh](delete-workload)
- Clone a deployment from another [clone-environment.sh](clone-environment.sh)
- Rollback one set to another [rollback.sh](rollback.sh)

# deployment scripts

- Wait for the last deployment to complete: Before deploying with score. [wait-for-deployment.sh](wait-for-deployment.sh)
- Wait for a specific delta/deployment to complete: After deployint with score [wait-for-delta.sh](wait-for-delta.sh)
- Wait for a specific automation to complete [wait-for-automation.sh](wait-for-automation.sh)

Example
```
curl \
 --request POST "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/artefact-versions" \
 --header "Authorization: Bearer ${HUMANITEC_TOKEN}" \
 --header "Content-Type: application/json" \
 --data-raw '{ 
     "name": "667740703053.dkr.ecr.ca-central-1.amazonaws.com/app1",
     "type": "container",
     "commit": "90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3",
     "version": "90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3",
     "ref":"refs/heads/main"
 }'

IMAGE_TO_FIND="667740703053.dkr.ecr.ca-central-1.amazonaws.com/app1:90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3"
bash wait-for-automation.sh

bash wait-for-deployment.sh
DELTA_ID = $(score delta (...) --deploy | jq .delta_id -r)
bash wait-for-delta.sh
```
