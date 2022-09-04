#!/bin/bash

echo "Project sign artifact..."

. ex/util/args/require $# 1

TAG="$1"

. ex/util/require REPOSITORY_NAME TAG KEYSTORE_PASSWORD KEY_ALIAS

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"

. ex/util/assert -f assemble/project/artifact/$ARTIFACT
. ex/util/assert -f assemble/project/${KEY_ALIAS}.pkcs12

echo "Sign \"$ARTIFACT\"..."
jarsigner \
 -keystore assemble/project/${KEY_ALIAS}.pkcs12 \
 -keypass "$KEYSTORE_PASSWORD" \
 -storepass "$KEYSTORE_PASSWORD" \
 -sigalg SHA512withRSA \
 -digestalg SHA-512 \
 assemble/project/artifact/$ARTIFACT ${KEY_ALIAS} > /dev/null \
 || . ex/util/throw 11 "Sign \"$ARTIFACT\" error!"
jarsigner -verify assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Verify \"$ARTIFACT\" error!"
