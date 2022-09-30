#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ci/workflow/pr/unstable/tag.sh

. ex/util/require TAG BUILD_VARIANT

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .name REPOSITORY_NAME

ARTIFACT="${REPOSITORY_NAME}-${TAG}.apk"

echo "Assemble \"$ARTIFACT\"..."
gradle -q -p "$REPOSITORY" app:assemble${BUILD_VARIANT^}Apk \
 || . ex/util/throw 11 "Assemble \"$ARTIFACT\" error!"

RELATIVE="$REPOSITORY/app/build/outputs/apk/${BUILD_VARIANT}"
. ex/util/assert -f $RELATIVE/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
echo "Install \"$ARTIFACT\"..."
mv $RELATIVE/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Install \"$ARTIFACT\" error!"
