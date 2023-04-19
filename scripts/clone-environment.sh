#!/usr/bin/env bash

# Usage: Provide variables then `NEW_ENVIRONMENT_TYPE=production NEW_ENVIRONMENT=prod COPY_FROM_ENVIRONMENT=development bash clone-environment.sh`

HUMANITEC_ORG=""
HUMANITEC_TOKEN=""
HUMANITEC_URL="https://api.humanitec.io"
APP_ID="app"


NEW_ENVIRONMENT_TYPE=production #actual env type
NEW_ENVIRONMENT=prod  #not env type, env name
COPY_FROM_ENVIRONMENT=development #not env type, env name



humanitec_clone_environment () {
    echo "Attempting to create a new environment: $NEW_ENVIRONMENT, $NEW_ENVIRONMENT_TYPE from $COPY_FROM_ENVIRONMENT"

    curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs/$COPY_FROM_ENVIRONMENT/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k

    DEPLOYMENT_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["id"]' -r`

    if [[ $DEPLOYMENT_ID  == "null" ]]
    then
        DEPLOYMENT_ID=`cat /tmp/deploys.json | jq '.[0]["id"]' -r`;
        echo "Could not found a successful deployment for the new environment, trying anything available: $DEPLOYMENT_ID"
    else
        echo "Found a successful deployment for the new environment: $DEPLOYMENT_ID"
    fi


cat <<-EOF > /tmp/new_environment.json
    {
    "from_deploy_id": "$DEPLOYMENT_ID",
    "id": "$NEW_ENVIRONMENT",
    "name": "$NEW_ENVIRONMENT",
    "type": "$NEW_ENVIRONMENT_TYPE"
    }
EOF

    STATUSCODE=$(curl -X POST -k --silent --output /dev/stderr --write-out "%{http_code}" $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$APP_ID/envs -H "Authorization: Bearer $HUMANITEC_TOKEN"  -d @/tmp/new_environment.json)
    
    if [[ $STATUSCODE  == 200 ]] || [[ $STATUSCODE  == 201 ]] || [[ $STATUSCODE == 409 ]] ; then
        echo "Environment creation OK: $STATUSCODE"
    else
        echo "Environment creation failure: $STATUSCODE"
        exit 1
    fi

}

humanitec_clone_environment
