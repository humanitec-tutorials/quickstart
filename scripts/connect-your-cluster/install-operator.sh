# These steps reiterate the commands seen at https://developer.humanitec.com/integration-and-extensions/humanitec-operator/installation/

set -eo pipefail

###
# Install the latest version
###
echo "### Installing the Humanitec Operator to your cluster"
helm install humanitec-operator \
  oci://ghcr.io/humanitec/charts/humanitec-operator \
  --namespace humanitec-operator-system \
  --create-namespace

###
# Configure authentication for Drivers
####
echo "### Preparing a key pair for the Operator"
# Generate a new private key
openssl genpkey -algorithm RSA -out humanitec_operator_private_key.pem -pkeyopt rsa_keygen_bits:4096
# Extract the public key from the private key generated in the previous command
openssl rsa -in humanitec_operator_private_key.pem -outform PEM -pubout -out humanitec_operator_public_key.pem

# Add a Secret to the Humanitec Operator 
kubectl --namespace humanitec-operator-system create secret generic humanitec-operator-private-key \
     --from-file=privateKey=humanitec_operator_private_key.pem \
     --from-literal=humanitecOrganisationID=$HUMANITEC_ORG

# Register the public key with the Humanitec Platform Orchestrator
echo "### Registering the Operator public key with the Platform Orchestrator"
export OPERATOR_PUBLIC_KEY_ID=$(humctl api post /orgs/${HUMANITEC_ORG}/keys \
  -d "$(cat humanitec_operator_public_key.pem | jq -sR)" \
  | jq .id | tr -d "\"")

###
# Configure the Kubernetes secret store to use for the Operator
###
echo "### Configuring the Kubernetes secret store to use for the Operator"

export SECRET_STORE_ID=quickstart-k8s-store
export SECRETS_NAMESPACE=quickstart-secrets

kubectl apply -f - << EOF
apiVersion: humanitec.io/v1alpha1
kind: SecretStore
metadata:
  name: ${SECRET_STORE_ID}
  namespace: humanitec-operator-system
  labels:
    app.humanitec.io/default-store: "true"
spec:
  kubernetes:
    namespace: ${SECRETS_NAMESPACE}
EOF

kubectl create ns ${SECRETS_NAMESPACE}