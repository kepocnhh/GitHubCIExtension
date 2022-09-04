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

echo "Verify jar \"$ARTIFACT\"..."
jarsigner -verify assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 11 "Verify jar \"$ARTIFACT\" error!"

echo "Verify \"${KEY_ALIAS^^}.SF\"..."
unzip -p assemble/project/artifact/$ARTIFACT META-INF/${KEY_ALIAS^^}.SF | openssl cms -sign -binary -noattr -outform DER \
 -signer <(keytool -keystore assemble/project/${KEY_ALIAS}.pkcs12 -storepass "$KEYSTORE_PASSWORD" -exportcert -rfc -alias ${KEY_ALIAS}) \
 -inkey <(openssl pkcs12 -in assemble/project/${KEY_ALIAS}.pkcs12 -nocerts -nodes -passin pass:"$KEYSTORE_PASSWORD") \
 -md sha512 | openssl cms -verify -noverify -content <(unzip -p assemble/project/artifact/$ARTIFACT META-INF/${KEY_ALIAS^^}.SF) -inform DER \
 || . ex/util/throw 12 "Verify \"${KEY_ALIAS^^}.SF\" error!"

echo "Verify \"${KEY_ALIAS^^}.RSA\"..."
unzip -p assemble/project/artifact/$ARTIFACT META-INF/${KEY_ALIAS^^}.RSA \
 | openssl cms -verify -noverify -content <(unzip -p assemble/project/artifact/$ARTIFACT META-INF/${KEY_ALIAS^^}.SF) -inform DER \
 || . ex/util/throw 13 "Verify \"${KEY_ALIAS^^}.RSA\" error!"

echo "Verify sig \"$ARTIFACT\"..."
openssl dgst -sha512 -verify <(keytool -keystore assemble/project/${KEY_ALIAS}.pkcs12 \
  -storepass "$KEYSTORE_PASSWORD" -exportcert -rfc -alias ${KEY_ALIAS} | openssl x509 -pubkey -noout) \
 -signature assemble/project/artifact/${ARTIFACT}.sig assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 14 "Verify sig \"$ARTIFACT\" error!"
