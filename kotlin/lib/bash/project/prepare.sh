#!/bin/bash

echo "Project prepare..."

. ex/util/require KEYSTORE KEYSTORE_PASSWORD KEYSTORE_FINGERPRINT

echo "$KEYSTORE" | base64 -d > assemble/project/key.pkcs12 \
 || . ex/util/throw 11 "Keystore error!"

ACTUAL_FINGERPRINT="$(openssl pkcs12 -in assemble/project/key.pkcs12 -nokeys -passin pass:"$KEYSTORE_PASSWORD" \
 | openssl x509 -noout -fingerprint -sha512)" \
 || . ex/util/throw 12 "Actual fingerprint error!"

EXPECTED_FINGERPRINT="SHA512 Fingerprint=$KEYSTORE_FINGERPRINT"
. ex/util/assert -eq EXPECTED_FINGERPRINT ACTUAL_FINGERPRINT

gradle -p repository clean \
 || . ex/util/throw 21 "Gradle clean error!"

gradle -p repository lib:compileKotlin \
 || . ex/util/throw 22 "Gradle compile error!"
