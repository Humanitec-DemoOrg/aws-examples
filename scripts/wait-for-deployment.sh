#!/usr/bin/env bash

# Usage: Provide variables then `bash wait-for-deployment.sh`

HUMANITEC_ORG=""
HUMANITEC_TOKEN=""
APP_ID="app"
ENV_ID="development" #not env type, use the env name
HUMANITEC_URL="https://api.humanitec.io"

humanitec_wait_for_deployment () {
    echo "Waiting for deployment: $HUMANITEC_ORG/$APP_ID/$ENV_ID"
    while :
    do
        sleep 3
        curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k
        DEPLOYMENT_STATUS=`cat /tmp/deploys.json | jq '.[0]["status"]' -r`
        DEPLOYMENT_ID=`cat /tmp/deploys.json | jq '.[0]["id"]' -r`
 
        if [[ $DEPLOYMENT_STATUS == "failed" ]]
        then
            echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$APP_ID/$ENV_ID/$DEPLOYMENT_ID"
            curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys/$DEPLOYMENT_ID/errors  -H "Authorization: Bearer $HUMANITEC_TOKEN" -k -s
            exit 1
        fi
        if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
        then
            echo "DEPLOYMENT OK: $HUMANITEC_ORG/$APP_ID/$ENV_ID/$DEPLOYMENT_ID"
            DEPLOYMENT_ID=""
            break
        fi
        echo $DEPLOYMENT_ID/$DEPLOYMENT_STATUS
    done
}

humanitec_wait_for_deployment
