#!/bin/bash

echo "Workflow pull request snapshot maven tag test..."

. ex/util/require MAVEN_GROUP_ID MAVEN_ARTIFACT_ID

BASE_URL="https://s01.oss.sonatype.org/content/repositories/snapshots/${MAVEN_GROUP_ID//.//}"

. ex/workflow/pr/snapshot/tag.sh

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null \
 "${BASE_URL}/${MAVEN_ARTIFACT_ID}/${TAG}/")
if test $CODE -ne 404; then
 ex/workflow/pr/snapshot/maven/tag/test/on_failed.sh; exit 11
fi
