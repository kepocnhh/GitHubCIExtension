#!/bin/bash

echo "Project sign artifact..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require TAG KEY_ALIAS KEYSTORE_PASSWORD

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME

ARTIFACT="${REPOSITORY_NAME}-${TAG}.apk"

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
