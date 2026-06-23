
cat << EOF > resdef-aws.yaml
# Connect to an EKS cluster using temporary credentials defined via a Cloud Account
apiVersion: entity.humanitec.io/v1b1
kind: Definition
metadata:
  id: ${CLOUD}-quickstart
entity:
  name: ${CLOUD}-quickstart
  type: k8s-cluster
  # The driver_account references a Cloud Account of type "aws-identity"
  # which needs to be configured for your Organization.
  driver_account: ${CLOUD_ACCOUNT_ID}
  driver_type: humanitec/k8s-cluster-eks
  driver_inputs:
    values:
      region: ${EKS_CLUSTER_REGION}
      name: ${EKS_CLUSTER_NAME}
  criteria:
  - app_id: quickstart
EOF

echo "EKS Resource Definition prepared at resdef-aws.yaml"