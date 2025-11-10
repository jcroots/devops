#!/bin/bash
#
# Generate gcloud credentials to be used in terraform github actions
#

set -eu

project_id=${1:?'project id?'}
bucket_name=${2:?'tf state bucket name?'}

iam_account="terraform-sa@${project_id}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create terraform-sa --project="${project_id}"

# Read-only for project
gcloud projects add-iam-policy-binding "${project_id}" \
	--member="serviceAccount:${iam_account}" \
	--role='roles/viewer' \
	--project="${project_id}"

# Write access only for the state bucket
gcloud storage buckets add-iam-policy-binding "gs://${bucket_name}" \
	--member="serviceAccount:${iam_account}" \
	--role='roles/storage.objectAdmin' \
	--project="${project_id}"


# Create and download key
gcloud iam service-accounts keys create ~/terraform-sa-credentials.json \
	--iam-account="${iam_account}" \
	--project="${project_id}"

exit 0
