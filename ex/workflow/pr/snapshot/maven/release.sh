#!/bin/bash

echo "Workflow pull request snapshot maven release..."

. ex/util/require MAVEN_GROUP_ID MAVEN_ARTIFACT_ID MAVEN_SNAPSHOT_USERNAME MAVEN_SNAPSHOT_PASSWORD

MAVEN_URL="https://s01.oss.sonatype.org/content/repositories/snapshots"

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

BASE_URL="${MAVEN_URL}/${MAVEN_GROUP_ID//.//}/${MAVEN_ARTIFACT_ID}/${TAG}"

ARTIFACT_NAME="${MAVEN_ARTIFACT_ID}-${TAG}.jar"
FILE="assemble/project/artifact/$ARTIFACT_NAME"
. ex/util/assert -f $FILE

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null -X POST "${BASE_URL}/${ARTIFACT_NAME}" \
 -u "${MAVEN_SNAPSHOT_USERNAME}:${MAVEN_SNAPSHOT_PASSWORD}" \
 -H 'Content-Type: text/plain' \
 --data-binary "@$FILE")
if test $CODE -ne 201; then
 echo "Maven upload ${FILE} error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

ARTIFACT_NAME="${MAVEN_ARTIFACT_ID}-${TAG}-sources.jar"
FILE="assemble/project/artifact/$ARTIFACT_NAME"
. ex/util/assert -f $FILE

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null -X POST "${BASE_URL}/${ARTIFACT_NAME}" \
 -u "${MAVEN_SNAPSHOT_USERNAME}:${MAVEN_SNAPSHOT_PASSWORD}" \
 -H 'Content-Type: text/plain' \
 --data-binary "@$FILE")
if test $CODE -ne 201; then
 echo "Maven upload ${FILE} error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

ARTIFACT_NAME="${MAVEN_ARTIFACT_ID}-${TAG}.pom"
FILE="assemble/project/artifact/$ARTIFACT_NAME"
. ex/util/assert -f $FILE

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null -X POST "${BASE_URL}/${ARTIFACT_NAME}" \
 -u "${MAVEN_SNAPSHOT_USERNAME}:${MAVEN_SNAPSHOT_PASSWORD}" \
 -H 'Content-Type: text/plain' \
 --data-binary "@$FILE")
if test $CODE -ne 201; then
 echo "Maven upload ${FILE} error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

exit 0
