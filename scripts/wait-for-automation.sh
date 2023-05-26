#!/usr/bin/env bash
set -e
# Usage: Provide variables then `bash wait-for-delta.sh`

HUMANITEC_ORG="myorg"
HUMANITEC_TOKEN="mytoken"
HUMANITEC_APP="app"
ENV_ID="development" #not env type, use the env name
HUMANITEC_URL="https://api.humanitec.io"
MAX_RETRIES_BEFORE_TIMEOUT=10
MAX_WAIT_BETWEEN_RETRIES=5

# format repository/app:commit
# curl \
# --request POST "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/artefact-versions" \
# --header "Authorization: Bearer ${HUMANITEC_TOKEN}" \
# --header "Content-Type: application/json" \
# --data-raw '{ 
#     "name": "667740703053.dkr.ecr.ca-central-1.amazonaws.com/app1",
#     "type": "container",
#     "commit": "90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3",
#     "version": "90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3",
#     "ref":"refs/heads/main"
# }'

IMAGE_TO_FIND="667740703053.dkr.ecr.ca-central-1.amazonaws.com/app1:90254ccc7352e1a5c8d1e4cdab2a032cefac9fd5d4d632ca003a2943c9a9b0a3"

# Scan images from current to at most 10 minutes in the future
if [ "$(uname)" == "Darwin" ]; then
    DATE_END=$(date -u -v+10M +%Y-%m-%dT%H:%M)
    DATE_START=$(date -u -v-1M +%Y-%m-%dT%H:%M)
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    DATE_END=$(date -u +%Y-%m-%dT%H:%M -d "+10mins")
    DATE_START=$(date -u +%Y-%m-%dT%H:%M -d "-1mins")
fi

humanitec_wait_for_automation () {
    COUNTER=0

    echo "Waiting for automation: $HUMANITEC_ORG/$HUMANITEC_APP/$ENV_ID"
   
    while [[ $COUNTER -lt $MAX_RETRIES_BEFORE_TIMEOUT ]]; do

        curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$ENV_ID/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k

        DEPLOYMENTS=$(cat /tmp/deploys.json | jq '[.[] | select(.created_by=="UNKNOWN")]' | jq --arg s "$DATE_START" --arg e "$DATE_END" 'map(select(.created_at | . >= $s and . <= $e + "z"))' | jq 'reverse')

        for row in $(echo "$DEPLOYMENTS" | jq -r '.[] | @base64'); do
            _jq() {
                echo "${row}" | base64 --decode | jq -r "${1}"
            }

            CREATED_AT=$(_jq '.created_at')
            DELTA_ID=$(_jq '.delta_id')
            DEPLOYMENT_STATUS=$(_jq '.status')
            DEPLOYMENT_ID=$(_jq '.id')


            DELTA_DATA=$(curl -s -k "$HUMANITEC_URL/orgs/${HUMANITEC_ORG}/apps/${HUMANITEC_APP}/deltas/${DELTA_ID}" -H "Authorization: Bearer ${HUMANITEC_TOKEN}")
            
            if grep -q "$IMAGE_TO_FIND" <<< "$DELTA_DATA"; then
                echo "IMAGE FOUND: $IMAGE_TO_FIND, DELTA ID: $DELTA_ID, DEPLOYMENT STATUS: $DEPLOYMENT_STATUS, CREATED AT: $CREATED_AT"
                COUNTER=$(( COUNTER - 1 ))
                echo
                if [[ $DEPLOYMENT_STATUS == "failed" ]]
                then
                    echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$HUMANITEC_APP/$ENV_ID/$DEPLOYMENT_ID/$DELTA_ID"
                    echo
                    echo "$DELTA_DATA" | jq -r
                    echo
                    curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$ENV_ID/deploys/"$DEPLOYMENT_ID"/errors  -H "Authorization: Bearer $HUMANITEC_TOKEN" -k -s | jq -r
                    exit 1

                fi
                if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
                then
                    echo "DEPLOYMENT OK: $HUMANITEC_ORG/$HUMANITEC_APP/$ENV_ID/$DEPLOYMENT_ID/$DELTA_ID"
                    echo
                    echo "$DELTA_DATA" | jq -r
                    echo
                    exit 0
                fi
                echo "Image found, waiting to complete."
                break
            fi
            echo "Another automation is running concurrently."

        done
        echo "Retrying..."
      
        COUNTER=$(( COUNTER + 1 ))
        sleep $MAX_WAIT_BETWEEN_RETRIES

    done

    if [[ $COUNTER == "$MAX_RETRIES_BEFORE_TIMEOUT" ]]
    then
        echo "AUTOMATION NOT FOUND: TIMEOUT"
        exit 1
    fi

}

humanitec_wait_for_automation
