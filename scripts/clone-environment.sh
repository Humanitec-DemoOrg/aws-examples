#!/usr/bin/env bash

export HUMANITEC_TOKEN=mytoken
export HUMANITEC_API_PREFIX=https://api.humanitec.io
export HUMANITEC_APP=myapp
export HUMANITEC_ORG=myorg

NEW_ENVIRONMENT_TYPE=prod #actual env type https://app.humanitec.io/orgs/$HUMANITEC_ORG/environment-types
NEW_ENVIRONMENT=production  # new env name, not env type
COPY_FROM_ENVIRONMENT=development #env name, not env type
FAIL_ON_DEPLOYMENT_FAILURE="false"


humanitec_clone_environment () {
    echo "Attempting to create a new environment named: $NEW_ENVIRONMENT, of type: $NEW_ENVIRONMENT_TYPE from environment name: $COPY_FROM_ENVIRONMENT"

    humctl get orgs 

    humctl create env $NEW_ENVIRONMENT --from $COPY_FROM_ENVIRONMENT --type $NEW_ENVIRONMENT_TYPE || true 
    
    DEPLOYMENT=`humctl deploy --env $COPY_FROM_ENVIRONMENT deploy . envs/$NEW_ENVIRONMENT -o json`
    DEPLOYMENT_ID=`echo $DEPLOYMENT | jq -r .metadata.id`

    echo $DEPLOYMENT_ID

    while :
    do
        export HUMANITEC_ENV=$NEW_ENVIRONMENT

        DEPLOYMENT_STATUS=`humctl get deploy $DEPLOYMENT_ID -o json | jq -r .status.status`
        echo $DEPLOYMENT_STATUS
        if [[ $DEPLOYMENT_STATUS == "failed" ]]
        then
            echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENV/$DEPLOYMENT_ID"
            humctl get deploy $DEPLOYMENT_ID -o json
            
            if [[ $FAIL_ON_DEPLOYMENT_FAILURE == "true" ]]
            then
                exit 1
            else
                echo "Continuing with failure..."
                break
            fi

        fi

        if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
        then
            echo "DEPLOYMENT OK: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENV/$DEPLOYMENT_ID"
            humctl get deploy $DEPLOYMENT_ID -o json
            break
        fi

        sleep 3

    done
}

humanitec_clone_environment
