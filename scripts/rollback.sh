#!/usr/bin/env bash

APP="myapp"
ENV="development"
ORG="myorg"
TOKEN="xxx"

CURRENT_SET="R5elhkqVtEx15tcaAz_8Xm6y71FSrQH09sKuXat99J8"
TARGET_SET="4-1xU4S3EKf2Pe2wXd9eJm9t-fV2TFFW6NZhDFdOvt0"

DIFF=`curl https://api.humanitec.io/orgs/$ORG/apps/$APP/sets/$TARGET_SET?diff=$CURRENT_SET -H "Authorization: Bearer $TOKEN" --silent`
echo $DIFF

DELTA=`curl -X POST https://api.humanitec.io/orgs/$ORG/apps/$APP/deltas -d $DIFF -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" --silent`
echo $DELTA

DEPLOYMENT="{\"delta_id\":"$DELTA",\"comment\":\"\"}"
DEPLOYMENT=`curl -X POST https://api.humanitec.io/orgs/$ORG/apps/$APP/envs/$ENV/deploys -d $DEPLOYMENT -H "Authorization: Bearer $TOKEN" --silent`
echo $DEPLOYMENT
