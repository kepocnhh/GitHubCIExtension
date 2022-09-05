#!/bin/bash

echo "Workflow pull request snapshot assemble project artifact..."

. ex/util/require REPOSITORY_NAME

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

. ex/workflow/pr/snapshot/tag.sh

rm -rf assemble/project/artifact
mkdir -p assemble/project/artifact

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotJar \
 || . ex/util/throw 111 "Assemble \"$ARTIFACT\" error!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 112 "Install \"$ARTIFACT\" error!"

ex/project/sign/artifact.sh "$TAG" || exit 113

ARTIFACT="${REPOSITORY_NAME}-${TAG}-sources.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotSource \
 || . ex/util/throw 121 "Assemble \"$ARTIFACT\" error!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 122 "Install \"$ARTIFACT\" error!"

ARTIFACT="${REPOSITORY_NAME}-${TAG}.pom"
gradle -p "$REPOSITORY" lib:assembleSnapshotPom \
 || . ex/util/throw 131 "Assemble \"$ARTIFACT\" error!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT \
 || . ex/util/throw 132 "Install \"$ARTIFACT\" error!"
