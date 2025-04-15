aws eks delete-access-entry \
  --cluster-name ${EKS_CLUSTER_NAME} \
  --principal-arn ${ROLE_ARN} \
  --region ${EKS_CLUSTER_REGION}

humctl delete -f aws-role-cloudaccount.yaml

aws iam detach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn ${POLICY_ARN} \
  --region ${EKS_CLUSTER_REGION}

aws iam delete-policy \
  --policy-arn ${POLICY_ARN} \
  --region ${EKS_CLUSTER_REGION}

aws iam delete-role \
  --role-name ${ROLE_NAME} \
  --region ${EKS_CLUSTER_REGION}

./scripts/cleanup/cleanup-operator.sh
