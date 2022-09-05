#!/bin/bash

echo "Workflow pull request snapshot maven release..."

. ex/util/require MAVEN_GROUP_ID MAVEN_ARTIFACT_ID MAVEN_USERNAME MAVEN_PASSWORD

MAVEN_URL="https://s01.oss.sonatype.org/content/repositories/snapshots"

. ex/workflow/pr/snapshot/tag.sh

BASE_URL="${MAVEN_URL}/${MAVEN_GROUP_ID//.//}/${MAVEN_ARTIFACT_ID}/${TAG}"

for ARTIFACT_NAME in \
 "${MAVEN_ARTIFACT_ID}-${TAG}.jar" \
 "${MAVEN_ARTIFACT_ID}-${TAG}.jar.sig" \
 "${MAVEN_ARTIFACT_ID}-${TAG}-sources.jar" \
 "${MAVEN_ARTIFACT_ID}-${TAG}.pom"; do
 FILE="assemble/project/artifact/$ARTIFACT_NAME"
 . ex/util/assert -f $FILE
 CODE=0
 CODE=$(curl -w %{http_code} -o /dev/null -X POST "${BASE_URL}/${ARTIFACT_NAME}" \
  -u "${MAVEN_USERNAME}:${MAVEN_PASSWORD}" \
  -H 'Content-Type: text/plain' \
  --data-binary "@$FILE")
 if test $CODE -ne 201; then
  echo "Maven upload ${FILE} error!"
  echo "Request error with response code $CODE!"
  exit 111
 fi
done
