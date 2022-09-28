#!/bin/bash

echo "Workflow pull request snapshot assemble project artifact..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ex/android/app/project/version.sh

. ex/util/require ARTIFACT_VERSION BUILD_VARIANT

. ex/util/jq/write REPOSITORY_NAME -sfs assemble/vcs/repository.json .name

ARTIFACT="${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk"

echo "Assemble \"$ARTIFACT\"..."
gradle -q -p "$REPOSITORY" app:assemble${BUILD_VARIANT^} \
 || . ex/util/throw 11 "Assemble \"$ARTIFACT\" error!"

RELATIVE="$REPOSITORY/app/build/outputs/apk/${BUILD_VARIANT}"
. ex/util/assert -f $RELATIVE/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
echo "Install \"$ARTIFACT\"..."
mv $RELATIVE/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Install \"$ARTIFACT\" error!"

ex/android/app/project/sign/artifact.sh "$ARTIFACT_VERSION" || exit 13
