#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
str1="0/1"
#指定statefulset有几个副本 0 2 表示有3个副本 即replicas: 3
for input0 in $(seq 0 2)
do
kubectl get pod | grep vault-"$input0"
if [ "$?" = 0 ]; then
	status=`kubectl get pod | grep vault | awk '{print $2}'`
		if [ "$status" = "$str1" ]; then
			for input1 in $(seq 0 2)
			do
				kubectl exec vault-"$input1" -- vault operator init -key-shares=1 -key-threshold=1 -format=json > keys.json
				VAULT_UNSEAL_KEY=$(cat keys.json | jq -r ".unseal_keys_b64[]")
				echo $VAULT_UNSEAL_KEY
				VAULT_ROOT_KEY=$(cat keys.json | jq -r ".root_token")
				echo $VAULT_ROOT_KEY
				kubectl exec vault-"$input1" -- vault operator unseal $VAULT_UNSEAL_KEY
				sleep 10
			done
			break
		else
			echo "false"
		fi
else
	echo "None.No vault pod."
fi
done
