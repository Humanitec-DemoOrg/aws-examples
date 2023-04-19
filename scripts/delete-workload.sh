#!/usr/bin/env bash

# Usage: Provide variables then `bash delete-workload.sh`

HUMANITEC_ORG=""
HUMANITEC_TOKEN=""
APP_ID="app"
ENV_ID="development" #not env type, use the env name
WORKLOAD="workload-to-delete"
HUMANITEC_URL="https://api.humanitec.io"


humanitec_delete_workload () {
DELTA=$(cat <<EOF
{
  "metadata": {
    "env_id": "${ENV_ID}"
  },
  "modules":{
     "remove":[
        "${WORKLOAD}"
     ]
  }
}
EOF
);

DELTA="$(curl -s \
"$HUMANITEC_URL/orgs/${HUMANITEC_ORG}/apps/${APP_ID}/deltas" -X POST \
-H "Authorization: Bearer ${HUMANITEC_TOKEN}" -H 'content-type: application/json'  --data "$DELTA" | jq -r  .id  )"

DELTA=$(cat <<EOF
{
   "delta_id":"$DELTA",
   "comment":""
}
EOF
);

SET="$(curl -s $HUMANITEC_URL/orgs/${HUMANITEC_ORG}/apps/${APP_ID}/envs/${ENV_ID}/deploys -X POST \
-H "Authorization: Bearer ${HUMANITEC_TOKEN}" -H 'content-type: application/json'  --data "$DELTA")"

echo $SET
}

humanitec_delete_workload
