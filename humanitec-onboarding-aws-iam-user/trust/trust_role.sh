export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_DEFAULT_REGION=ca-central-1
export AWS_ACCOUNT="012345678901"
export EXTERNAL_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

export HUMANITEC_ORG=xxx
export HUMANITEC_TOKEN=xxx

cat <<EOF > /tmp/trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::767398028804:user/humanitec"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${EXTERNAL_ID}"
        }
      }
    }
  ]
}
EOF

export ROLE_NAME=humanitec-${EXTERNAL_ID}

export ROLE_ARN=$(aws iam create-role --role-name ${ROLE_NAME} \
  --assume-role-policy-document file:///tmp/trust-policy.json \
  | jq .Role.Arn | tr -d "\"")
echo ${ROLE_ARN}

cat <<EOF > /tmp/role-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
export POLICY_NAME=humanitec-${EXTERNAL_ID}

export POLICY_ARN=$(aws iam create-policy \
  --policy-name ${POLICY_NAME} \
  --policy-document file:///tmp/role-policy.json \
  | jq .Policy.Arn | tr -d "\"")
echo ${POLICY_ARN}

aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn ${POLICY_ARN}

humctl api post /orgs/${HUMANITEC_ORG}/resources/accounts \
-d '{
  "name": "'"${AWS_ACCOUNT}"'",
  "id": "'"${AWS_ACCOUNT}"'",
  "type": "aws-role",
  "credentials": {
    "aws_role": "'"${ROLE_ARN}"'",
    "external_id": "'"${EXTERNAL_ID}"'"
  }
}
'
