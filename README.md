# kubernetes-vault
Kubernetes manifests to setup Hashicorp vault server

Full Documentation: https://devopscube.com/vault-in-kubernetes/

#Sample API request to the vault using service account tokens to acquire a token with reading capabilities for path "demo-app"

```
curl --request POST --data '{"jwt": "<< service account token of the pod >>", "role": "webapp"}' http://192.168.49.2:30493/v1/auth/kubernetes/login
```

#Sample API request to the vault to fetch secrets at "demo-app"

```
curl -H "X-Vault-Token: <client_token>" -H "X-Vault-Namespace: vault" -X GET http://192.168.49.2:30493/v1/demo-app/data/user01?version=1
```

## Vault Usage

### Initialize the vault.

```kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > keys.json

VAULT_UNSEAL_KEY=$(cat keys.json | jq -r ".unseal_keys_b64[]")
echo $VAULT_UNSEAL_KEY

VAULT_ROOT_KEY=$(cat keys.json | jq -r ".root_token")
echo $VAULT_ROOT_KEY
```

### Unseal the vault

```kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY	```

### Login into the vault
```kubectl exec vault-0 -- vault login $VAULT_ROOT_KEY```

### Create secrets 

```vault secrets enable -version=2 -path="demo-app" kv```

### Create key-value pairs
```vault kv put demo-app/user01 name=devopscube
vault kv get demo-app/user01 
```
###Create policies
```vault policy write demo-policy - <<EOH
path "demo-app/*" {
  capabilities = ["read"]
}
EOH
```

### vault policy list

#Enable Kubernetes authentication methods
```vault auth enable kubernetes

vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=demo-policy \
        ttl=72h
        ```
