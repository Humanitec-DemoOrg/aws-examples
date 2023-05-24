# diff-howto
How to generate a diff before deploying an environment

## Steps
- Prep env variables
```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export HUMANITEC_APP="myapp"
export HUMANITEC_ENVIRONMENT="development" #environment name, not environment type
```
- Generate a delta from your Score file
```
DELTA=`score-humanitec delta --api-url $HUMANITEC_URL --token $HUMANITEC_TOKEN \
    --org $HUMANITEC_ORG --app $HUMANITEC_APP --env $HUMANITEC_ENVIRONMENT -f score.yaml | jq 'del(.metadata.url)'`
DELTA_ID=`echo $DELTA | jq -r .id`
```

- Obtain the current Set ID and the Delta ID
```
CURRENT_SET_ID="$(curl -s \
  "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/envs/${HUMANITEC_ENVIRONMENT}" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" | jq -r .last_deploy.set_id)"

CURRENT_DELTA_ID="$(curl -s \
  "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/envs/${HUMANITEC_ENVIRONMENT}" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" | jq -r .last_deploy.delta_id)"
```

- Create a new Set ID, provide the raw delta as payload
```
NEW_SET_ID="$(curl -s \
  -X POST \
  "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/sets/${CURRENT_SET_ID}" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${DELTA}" | jq -r .)"
  ```

- Generate Diff, use this to approve the deployment. 
This is similar to a `terraform plan` as is just valid as long as there are no other concurrent deployments happening
```
curl -s \
  "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/sets/${NEW_SET_ID}/diff/${CURRENT_SET_ID}" \
  -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
  -H "Content-Type: application/json"
```

- Deploy new delta
```
curl -s -X \
POST -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
 -H \
 "Content-type: application/json" -d '{
"comment": "",
"delta_id": "'"${DELTA_ID}"'"
}' "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/envs/${HUMANITEC_ENVIRONMENT}/deploys"
```


