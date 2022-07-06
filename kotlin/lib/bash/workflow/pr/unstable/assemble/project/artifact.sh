#!/bin/bash

echo "Workflow pull request unstable assemble project artifact..."

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ex/workflow/pr/unstable/tag.sh

. ex/util/require REPOSITORY_NAME TAG

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"

gradle -p "$REPOSITORY" lib:assembleUnstableJar \
 || . ex/util/throw 12 "Assemble \"$ARTIFACT\" error $CODE!"

. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT

rm assemble/project/artifact/$ARTIFACT
mkdir -p assemble/project/artifact
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

exit 0
