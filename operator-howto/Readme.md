# operator-howto

## Steps to run the Operator
Please read the Official Humanitec Operator Beta Documentation. This page is a reference to common configuration issues.


- Install and unseal https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-amazon-eks
    - Adjust accordingly the commands and protocols, by default it's installed under the `default` namespace and without TLS
- Obtain your root token (or a non root one with ttl)
- Enable KV store: `kubectl exec vault-0 -- vault secrets enable -path=secret kv-v2`
- Follow the Operator Installation
    - Register your public key with the Platform Orchestrator
- Create a SecretStore in Humanitec
```
curl https://api.humanitec.io/orgs/${HUMANITEC_ORG}/secretstores -X POST \
-H "Authorization: Bearer ${HUMANITEC_TOKEN}" \
-H "Content-Type: application/json" \
-d '{
   "id":"my-secret-store",
   "primary":true,
   "vault":{
      "url":"http://vault.default.svc.cluster.local:8200",
      "auth":{
         "token":"hvs.xxx"
      }
   }
}'
```
- Create secret token (example with root credentials) `kubectl create secret generic vault-secret --from-literal=token="hvs.xxx" -n humanitec-operator-system`
- Configure your Local Operator
```
apiVersion: humanitec.io/v1alpha1
kind: SecretStore
metadata:
  name: my-secret-store
  namespace: humanitec-operator-system
spec:
  vault:
    url: "http://vault.default.svc.cluster.local:8200"
    auth:
      tokenSecretRef:
        name: vault-secret
        key: token
```
- Note the IDs from your Operator and Humanitec Secret Store must match

## Private Agent
- Contact Customer Service to setup your agent

## Debugging
- Describe resources within your namespace `kubectl describe resources -n namespace`

## Known Issues
- Currently vaults should be configured centrally across environments. A vault per cluster is not currently supported.
- Vaults are shared across multiple clusters, access to the vaults (security groups) should be configured accordingly
- Vaults will need to have their own Private Agent
