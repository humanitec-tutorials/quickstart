# These steps reiterate the commands seen at https://developer.humanitec.com/platform-orchestrator/security/cloud-accounts/aws/

# Create a non-guessable ExternalId that will uniquely identify the Cloud Account in the Humanitec Platform Orchestrator.
export EXTERNAL_ID=$(uuidgen)

# Create an IAM role to establish a trust relationship between your trusting account and the public Humanitec AWS user
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::360308478938:user/humanitec"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${EXTERNAL_ID}"
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
  | jq .Role.Arn | tr -d "\"")
echo ${ROLE_ARN}

# Define the name and id of the new Cloud Account
export CLOUD_ACCOUNT_NAME="Quickstart AWS"
export CLOUD_ACCOUNT_ID=quickstart-aws

# Create a file defining the Cloud Account you want to create
cat << EOF > aws-role-cloudaccount.yaml
apiVersion: entity.humanitec.io/v1b1
kind: Account
metadata:
  id: ${CLOUD_ACCOUNT_ID}
entity:
  name: ${CLOUD_ACCOUNT_NAME}
  type: aws-role
  credentials:
    aws_role: ${ROLE_ARN}
    external_id: ${EXTERNAL_ID}
EOF

# Use the humctl create command to create the Cloud Account
humctl apply -f aws-role-cloudaccount.yaml
