#!/usr/bin/env bash


source "../scripts/helper_create_workspace.sh"

mkdir -p ~/.terraform.d/
cat <<-EOF > ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "$TFE_TOKEN"
    }
  }
}
EOF

export TF_VAR_HUMANITEC_ENV=shared
export TF_WORKSPACE=shared

export TF_CLOUD_HOSTNAME=app.terraform.io
cd shared
create_workspace
tofu init
tofu plan
tofu apply -auto-approve
cd ..

cd development
export TF_VAR_HUMANITEC_ENV=development
export TF_WORKSPACE=development
create_workspace
tofu init
tofu plan
tofu apply -auto-approve
cd ..

cd production
export TF_VAR_HUMANITEC_ENV=production
export TF_WORKSPACE=production
create_workspace
tofu init
tofu plan
tofu apply -auto-approve
cd ..
