# rbac-howto

## Use cases
1. Allow developers to deploy to the development environment, do not allow developers to create apps, lock down every other environment.
1. Create Admin or Scoped token for CI/CD.
1. Create a custom namespace and add dynamic RBAC access within Kubernetes.

### 1. Allow developers to deploy to the development environment, do not allow developers to create apps, lock down every other environment.

- Login as `Administrator`.
- Add your developers as `Org members`, and set them with the role of `Member` See [images/create-user.png](images/create-user.png).
- Configure your `Environment Types`, for the environment types where developers can deploy to see [images/environment-types.png](images/environment-types.png).
- For each `Environment Type`, where you'd like people to deploy to, manage the `deployers`, add all the users that need deployment access see [images/deployers.png](images/deployers.png).
- For each app, under `App Settings`, add `App Members` with the role of `Developer`. See [images/app-settings.png](images/app-settings.png) and [images/app-developer.png](images/app-developer.png)

### 1. Create Admin or Scoped token for CI/CD
- For your CI/CD process, with your `Org Token` create a `Service User`. Users can be `Member` and be scoped the same way your developers are, you could create tokens for each `environment type` and `app` as needed. Service Users are identified by their e-mail. This email does not need to exist, but it's a convenience to find them quickly within the list of users. This feature is not available within the UI at this moment.

```
export HUMANITEC_ORG="myorg"
export HUMANITEC_TOKEN="mytoken"
export HUMANITEC_SERVICE_ACCOUNT_ID=`curl -s -X \
POST -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
 -H \
 "Content-type: application/json" -d '{
"name": "admin sa",
"email": "admin1@example.com",
"role": "administrator"
}' "https://api.humanitec.io/orgs/${HUMANITEC_ORG}/users" | jq -r .id`
echo $HUMANITEC_SERVICE_ACCOUNT_ID

```
- Create a token, and use it within your CI/CD pipeline
```
export HUMANITEC_SERVICE_ACCOUNT_TOKEN=`curl -s  -X \
POST -H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
 -H \
 "Content-type: application/json" -d '{
"description": "admin sa for admin1@example.com",
"type": "static",
"id": "sa-admin1-at-example-dot-com"
}' "https://api.humanitec.io/users/${HUMANITEC_SERVICE_ACCOUNT_ID}/tokens" | jq -r .token `
echo $HUMANITEC_SERVICE_ACCOUNT_TOKEN
```

### 1. Create a custom namespace and add dynamic RBAC access within Kubernetes.
- Install [https://rbac-manager.docs.fairwinds.com/introduction/#getting-started](https://rbac-manager.docs.fairwinds.com/introduction/#getting-started) or an alternative. Humanitec does not provide support to specific operators, nor recommends specific configurations. Please contact your DevSecOps team for more information on how to configure your RBAC and/or the right approach to do so.
- Configure your groups and users as usual.
- Configure a `base-env` as [terraform/base-env.tf](terraform/base-env.tf) with a manifest. In the example, we added a `development` group with different access than the `administrator` group.
- Access is controlled via namespace labels, as defined in [terraform/namespace.tf](terraform/namespace.tf)