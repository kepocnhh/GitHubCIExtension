#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ex/workflow/pr/unstable/tag.sh

. ex/util/require REPOSITORY_NAME TAG

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"

gradle -p "$REPOSITORY" lib:assembleUnstableJar \
 || . ex/util/throw 11 "Assemble \"$ARTIFACT\" error!"

. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 12 "Install \"$ARTIFACT\" error!"

ex/project/sign/artifact.sh "$TAG" || exit 13
