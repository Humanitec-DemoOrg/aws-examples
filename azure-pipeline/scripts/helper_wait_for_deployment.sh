# HUMANITEC_ORG=""
# HUMANITEC_TOKEN=""
# HUMANITEC_APP="app"
# HUMANITEC_ENV="development" #not env type, use the env name
export HUMANITEC_URL="https://api.humanitec.io"
FAIL_ON_DEPLOYMENT_FAILURE="false"

humanitec_wait_for_deployment () {
    echo "Waiting for deployment: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENV"
    while :
    do
        sleep 3
        curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_ENV/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k
        DEPLOYMENT_STATUS=`cat /tmp/deploys.json | jq '.[0]["status"]' -r`
        DEPLOYMENT_ID=`cat /tmp/deploys.json | jq '.[0]["id"]' -r`

        if [[ $DEPLOYMENT_ID == "null" ]]
        then
            echo "DEPLOYMENT NOT FOUND OR EMPTY"
            echo "Continuing..."
            break
        fi
 
        if [[ $DEPLOYMENT_STATUS == "failed" ]]
        then
            echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENV/$DEPLOYMENT_ID"
            curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_ENV/deploys/$DEPLOYMENT_ID/errors  -H "Authorization: Bearer $HUMANITEC_TOKEN" -k -s
            
            if [[ $FAIL_ON_DEPLOYMENT_FAILURE == "true" ]]
            then
                exit 1
            else
                echo "Continuing..."
                break
            fi

        fi
        if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
        then
            echo "DEPLOYMENT OK: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENV/$DEPLOYMENT_ID"
            DEPLOYMENT_ID=""
            break
        fi
        echo $DEPLOYMENT_ID/$DEPLOYMENT_STATUS
    done
}
