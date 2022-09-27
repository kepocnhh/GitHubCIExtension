#!/bin/bash

echo "Project prepare..."

. ex/util/require KEYSTORE_PASSWORD KEY_ALIAS BUILD_VARIANT

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

RESOURCES=$REPOSITORY/app/src/$BUILD_VARIANT/resources
cp assemble/project/${KEY_ALIAS}.pkcs12 $RESOURCES/key.pkcs12 \
 || . ex/util/throw 11 "Install keystore error!"

echo "password=${KEYSTORE_PASSWORD//"\\"/"\\\\"}" > $RESOURCES/properties \
 || . ex/util/throw 12 "Install keystore password error!"

echo "Clean..."
gradle -q -p $REPOSITORY clean \
 || . ex/util/throw 21 "Gradle clean error!"

echo "Compile..."
gradle -q -p $REPOSITORY app:compile${BUILD_VARIANT}Sources \
 || . ex/util/throw 22 "Gradle compile \"${BUILD_VARIANT}\" error!"
