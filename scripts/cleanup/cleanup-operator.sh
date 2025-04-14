echo "### Removing the Humanitec Operator"

kubectl delete ns ${SECRETS_NAMESPACE}
kubectl delete secretstore -n humanitec-operator-system ${SECRET_STORE_ID}

humctl api delete /orgs/${HUMANITEC_ORG}/keys/${OPERATOR_PUBLIC_KEY_ID}
rm humanitec_operator_private_key.pem
rm humanitec_operator_public_key.pem

helm uninstall humanitec-operator \
  --namespace humanitec-operator-system

kubectl delete ns humanitec-operator-system
