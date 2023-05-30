#!/usr/bin/env bash
set -e
# Usage: Provide variables then `bash wait-for-delta.sh`

HUMANITEC_ORG="myorg"
HUMANITEC_TOKEN="mytoken"
APP_ID="app"
ENV_ID="development" #not env type, use the env name
HUMANITEC_URL="https://api.humanitec.io"
FAIL_ON_FAILED_DEPLOYMENT="true"
FAIL_ON_EMPTY_DEPLOYMENT="true"
#PROVIDE A DELTA TO VERIFY DEPLOYMENT Example: `score-humanitec delta .... --deploy | jq .id -r`
DELTA_ID="e87b70928e0a13a54d2fb461873eef8ee877eeb0"

humanitec_wait_for_delta () {
    echo "Waiting for delta: $HUMANITEC_ORG/$APP_ID/$ENV_ID/$DELTA_ID"
    while :
    do
        curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k
        
        DEPLOYMENT=`cat /tmp/deploys.json | jq '.[] | select(.delta_id=="'"${DELTA_ID}"'")' -r`

        DEPLOYMENT_STATUS=`echo $DEPLOYMENT | jq '.status' -r`
        DEPLOYMENT_ID=`echo $DEPLOYMENT | jq '.id' -r`

        if [[ $DEPLOYMENT == "" ]]
        then
            echo "DEPLOYMENT NOT FOUND OR EMPTY"

            if [[ $FAIL_ON_EMPTY_DEPLOYMENT == "true" ]]
            then
                exit 1
            else
                echo "Continuing with an empty deployment"
                break
            fi
        fi
 
        if [[ $DEPLOYMENT_STATUS == "failed" ]]
        then
            echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$APP_ID/$ENV_ID/$DEPLOYMENT_ID/$DELTA_ID"
            echo
            curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys/$DEPLOYMENT_ID/errors  -H "Authorization: Bearer $HUMANITEC_TOKEN" -k -s
            
            if [[ $FAIL_ON_FAILED_DEPLOYMENT == "true" ]]
            then
                exit 1
            else
                echo "Continuing with a deployment failure"
                break
            fi

        fi
        if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
        then
            echo "DEPLOYMENT OK: $HUMANITEC_ORG/$APP_ID/$ENV_ID/$DEPLOYMENT_ID/$DELTA_ID"
            break
        fi
        echo $DEPLOYMENT_ID/$DEPLOYMENT_STATUS
        sleep 3
    done
}

humanitec_wait_for_delta
