#!/usr/bin/env bash

# Requires: $TF_CLOUD_ORGANIZATION, $TF_WORKSPACE, $TFE_TOKEN

create_workspace() {
rm /tmp/workspace.json || true
cat <<-EOL > /tmp/workspace.json
{
    "data": {
        "attributes": {
            "name": "$TF_WORKSPACE"
        },
        "type": "workspaces"
    }
}
EOL
curl -H 'Content-Type: application/vnd.api+json' -d @/tmp/workspace.json -H "Authorization: Bearer $TFE_TOKEN" -X POST https://app.terraform.io/api/v2/organizations/$TF_CLOUD_ORGANIZATION/workspaces || true
rm /tmp/workspace.json || true
}