#!/bin/bash

echo "Project sign artifact..."

. ex/util/args/require $# 1

ARTIFACT_VERSION="$1"

. ex/util/require ARTIFACT_VERSION KEY_ALIAS

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name

ARTIFACT="${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk"

. ex/util/assert -f \
 assemble/project/artifact/$ARTIFACT \
 assemble/project/${KEY_ALIAS}.pkcs12

echo "Sign \"$ARTIFACT\"..."
openssl dgst -sha512 \
 -sign <(openssl pkcs12 -in assemble/project/${KEY_ALIAS}.pkcs12 \
  -nocerts -passin pass:"$KEYSTORE_PASSWORD" -passout pass:"$KEYSTORE_PASSWORD") \
 -passin pass:"$KEYSTORE_PASSWORD" \
 -out assemble/project/artifact/${ARTIFACT}.sig assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 11 "Sign \"$ARTIFACT\" error!"
