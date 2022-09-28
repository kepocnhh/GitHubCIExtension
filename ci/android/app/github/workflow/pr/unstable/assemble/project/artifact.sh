#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ex/android/app/project/version.sh

. ex/util/require ARTIFACT_VERSION BUILD_VARIANT

REPOSITORY_NAME=$(ex/util/jqx -sfs assemble/vcs/repository.json .name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"

ARTIFACT="${REPOSITORY_NAME}-${ARTIFACT_VERSION}.apk"

gradle -q -p "$REPOSITORY" app:assemble${BUILD_VARIANT^} \
 || . ex/util/throw 11 "Assemble \"$ARTIFACT\" error!"

RELATIVE="$REPOSITORY/app/build/outputs/apk/${BUILD_VARIANT}"
. ex/util/assert -f $RELATIVE/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
mv $RELATIVE/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Install \"$ARTIFACT\" error!"

ex/android/app/project/sign/artifact.sh "$ARTIFACT_VERSION" || exit 13 # todo
