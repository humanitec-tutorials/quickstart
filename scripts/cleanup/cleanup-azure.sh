az role assignment delete \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope ${AKS_CLUSTER_ID} \
  --assignee ${MANAGED_IDENTITY_PRINCIPAL_ID}

az role assignment delete \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope ${AKS_CLUSTER_ID} \
  --assignee ${MANAGED_IDENTITY_PRINCIPAL_ID}

humctl delete -f azure-identity-cloudaccount.yaml

az identity delete \
  --name ${MANAGED_IDENTITY_NAME} \
  --resource-group ${MANAGED_IDENTITY_RESOURCE_GROUP}

./scripts/cleanup/cleanup-operator.sh
