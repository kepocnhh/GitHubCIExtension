#!/bin/bash

echo "Project prepare..."

. ex/util/require KEYSTORE KEYSTORE_PASSWORD KEY_ALIAS KEY_X509_SHA512

echo "$KEYSTORE" | base64 -d > assemble/project/${KEY_ALIAS}.pkcs12 \
 || . ex/util/throw 11 "Keystore error!"

ACTUAL_FINGERPRINT="$(keytool -keystore assemble/project/${KEY_ALIAS}.pkcs12 -storepass "$KEYSTORE_PASSWORD" \
 -exportcert -rfc -alias ${KEY_ALIAS} \
 | openssl x509 -noout -fingerprint -sha512)" \
 || . ex/util/throw 12 "Actual fingerprint error!"

. ex/util/assert -eqv "SHA512 Fingerprint=$KEY_X509_SHA512" "$ACTUAL_FINGERPRINT"

gradle -p repository clean \
 || . ex/util/throw 21 "Gradle clean error!"

gradle -p repository lib:compileKotlin \
 || . ex/util/throw 22 "Gradle compile error!"
