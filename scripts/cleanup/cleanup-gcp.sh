gcloud projects remove-iam-policy-binding ${GCP_PROJECT_ID} \
  --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/container.admin" \
  --quiet

humctl delete -f gcp-identity-cloudaccount.yaml

gcloud iam service-accounts remove-iam-policy-binding \
  ${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
  --member=principal://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/subject/${HUMANITEC_ORG}/${CLOUD_ACCOUNT_ID} \
  --role=roles/iam.workloadIdentityUser

gcloud iam service-accounts delete ${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
  --project=${GCP_PROJECT_ID} --quiet

gcloud iam workload-identity-pools delete ${WIF_POOL_NAME} \
  --location="global" --quiet

./scripts/cleanup/cleanup-operator.sh
