#!/bin/bash

echo "Project sign artifact verify..."

. ex/util/args/require $# 1

ARTIFACT_VERSION="$1"

. ex/util/require ARTIFACT_VERSION KEY_ALIAS KEYSTORE_PASSWORD

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

ARTIFACT="${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk"

ARTIFACT_PATH=assemble/project/artifact/$ARTIFACT
KEYSTORE_PATH=assemble/project/${KEY_ALIAS}.pkcs12

. ex/util/assert -f \
 $ARTIFACT_PATH \
 ${ARTIFACT_PATH}.sig \
 $KEYSTORE_PATH

echo "Verify artifact \"$ARTIFACT\"..."
jarsigner -verify $ARTIFACT_PATH \
 || . ex/util/throw 11 "Verify artifact \"$ARTIFACT\" error!"

ISSUER="CERT.SF"
echo "Verify \"$ISSUER\"..."
unzip -p $ARTIFACT_PATH META-INF/$ISSUER | openssl cms -sign -binary -noattr -outform DER \
 -signer <(keytool -keystore $KEYSTORE_PATH -storepass "$KEYSTORE_PASSWORD" -exportcert -rfc -alias ${KEY_ALIAS}) \
 -inkey <(openssl pkcs12 -in $KEYSTORE_PATH -nocerts -nodes -passin pass:"$KEYSTORE_PASSWORD") \
 -md sha512 | openssl cms -verify -noverify -content <(unzip -p $ARTIFACT_PATH META-INF/$ISSUER) -inform DER \
 || . ex/util/throw 12 "Verify \"$ISSUER\" error!"

ISSUER="CERT.RSA"
echo "Verify \"$ISSUER\"..."
unzip -p $ARTIFACT_PATH META-INF/$ISSUER \
 | openssl cms -verify -noverify -content <(unzip -p $ARTIFACT_PATH META-INF/CERT.SF) -inform DER \
 || . ex/util/throw 13 "Verify \"$ISSUER\" error!"

echo "Verify sig \"$ARTIFACT\"..."
openssl dgst -sha512 -verify <(keytool -keystore $KEYSTORE_PATH \
  -storepass "$KEYSTORE_PASSWORD" -exportcert -rfc -alias ${KEY_ALIAS} | openssl x509 -pubkey -noout) \
 -signature ${ARTIFACT_PATH}.sig $ARTIFACT_PATH \
 || . ex/util/throw 14 "Verify sig \"$ARTIFACT\" error!"
