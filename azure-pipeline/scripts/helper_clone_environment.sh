#!/usr/bin/env bash

# Make sure to download humctl
# https://developer.humanitec.com/platform-orchestrator/cli/
# https://developer.humanitec.com/platform-orchestrator/reference/cli-references/

# export HUMANITEC_TOKEN=mytoken
# export HUMANITEC_APP=myapp
# export HUMANITEC_ORG=myorg

# TARGET_ENVIRONMENT_TYPE=prod #actual env type https://app.humanitec.io/orgs/$HUMANITEC_ORG/environment-types
# TARGET_ENVIRONMENT=production  # new env name, not env type
# SOURCE_ENVIRONMENT=development #env name, not env type
FAIL_ON_DEPLOYMENT_FAILURE="false"


humanitec_clone_environment () {
    echo "Attempting to create a new environment named: $TARGET_ENVIRONMENT, of type: $TARGET_ENVIRONMENT_TYPE from environment name: $SOURCE_ENVIRONMENT"

    humctl get orgs 

    humctl create env $TARGET_ENVIRONMENT --from $SOURCE_ENVIRONMENT --type $TARGET_ENVIRONMENT_TYPE || true 
    
    DEPLOYMENT=`humctl deploy --env $SOURCE_ENVIRONMENT deploy . envs/$TARGET_ENVIRONMENT -o json`
    DEPLOYMENT_ID=`echo $DEPLOYMENT | jq -r .metadata.id`

    echo $DEPLOYMENT_ID

    while :
    do
        export HUMANITEC_ENV=$TARGET_ENVIRONMENT

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