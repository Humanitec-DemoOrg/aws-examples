#!/usr/bin/env bash

# Usage: Provide variables then `bash rollback-environment.sh`

HUMANITEC_ORG=""
HUMANITEC_TOKEN=""
HUMANITEC_ORG="nickhumanitec"
HUMANITEC_TOKEN="V8Q7XXQ6yPH1oxbrDswxLq0WafRzj_Zds_QZkR_spneE"
APP_ID="app"
ENV_ID="development"  #not env type, use the env name
HUMANITEC_URL="https://api.humanitec.io"

humanitec_rollback_environment() {
    echo "Trying to rollback to a successful deployment..."

    curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -k -s

    DEPLOYMENT_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["id"]' -r`
    COMMENT=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["comment"]' -r`
    CREATED_AT=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["created_at"]' -r`
    ENV_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["env_id"]' -r`

    if [[ $DEPLOYMENT_ID  == "null" ]]
    then
        echo "Could not found a successful deployment - doing nothing."
        exit -1
    else
        echo "Found a successful deployment: $DEPLOYMENT_ID, rollback requested."
cat <<-EOF > /tmp/rollback.json
{
"comment": "Rollback to $DEPLOYMENT_ID, $COMMENT, $CREATED_AT",
"delta_id": "$DELTA_ID"
}
EOF
        curl -X POST $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$ENV_ID/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN"  -d @/tmp/rollback.json -k -s
    fi

}

humanitec_rollback_environment