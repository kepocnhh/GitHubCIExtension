#!/bin/bash

echo "Project sign artifact verify..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require REPOSITORY_NAME TAG KEYSTORE_PASSWORD KEY_ALIAS

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"

. ex/util/assert -f \
 assemble/project/artifact/$ARTIFACT \
 assemble/project/artifact/${ARTIFACT}.sig \
 assemble/project/${KEY_ALIAS}.pkcs12

jarsigner -verify assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 11 "Verify jar \"$ARTIFACT\" error!"

openssl dgst -sha512 \
 -verify <(keytool -keystore assemble/project/${KEY_ALIAS}.pkcs12 \
  -storepass "$KEYSTORE_PASSWORD" -exportcert -rfc -alias ${KEY_ALIAS} | openssl x509 -pubkey -noout) \
 -signature assemble/project/artifact/${ARTIFACT}.sig assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Verify \"$ARTIFACT\" error!"
