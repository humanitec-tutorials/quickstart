# These steps reiterate the commands seen at https://developer.humanitec.com/platform-orchestrator/security/cloud-accounts/aws/

# Define the name and id of the new Cloud Account
export CLOUD_ACCOUNT_NAME="Quickstart AWS"
export CLOUD_ACCOUNT_ID=quickstart-aws

# Create an IAM OpenID Connect (OIDC) Identity Provider trusting the Humanitec issuer, and capture its ARN
export OIDC_PROVIDER_ARN=$(aws iam create-open-id-connect-provider \
  --url https://idtoken.humanitec.io \
  --client-id-list sts.amazonaws.com \
  --query OpenIDConnectProviderArn --output text)

# Create an IAM role for Web Identity Federation via OIDC
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "idtoken.humanitec.io:sub": "${HUMANITEC_ORG}/${CLOUD_ACCOUNT_ID}",
          "idtoken.humanitec.io:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Define the name of the new role according to your own naming schema
export ROLE_NAME=quickstart-aws-cloudaccount

# Create the IAM role including the trust policy and capture its ARN
export ROLE_ARN=$(aws iam create-role --role-name ${ROLE_NAME} \
  --assume-role-policy-document file://trust-policy.json \
  | jq -r .Role.Arn )
echo ${ROLE_ARN}


# Create a file defining the Cloud Account you want to create
cat << EOF > aws-identity-cloudaccount.yaml
apiVersion: entity.humanitec.io/v1b1
kind: Account
metadata:
  id: ${CLOUD_ACCOUNT_ID}
entity:
  name: ${CLOUD_ACCOUNT_NAME}
  type: aws-identity
  credentials:
    aws_identity_role_arn: ${ROLE_ARN}
EOF

# Use the humctl create command to create the Cloud Account
humctl apply -f aws-identity-cloudaccount.yaml
