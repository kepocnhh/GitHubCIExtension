#!/bin/bash

echo "Workflow pull request snapshot assemble project artifact..."

. ex/util/require REPOSITORY_NAME

REPOSITORY=repository
. ex/util/assert -d $REPOSITORY

VERSION_NAME=$(ex/util/jqx -sfs assemble/project/common.json .version.name) \
 || . ex/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

rm -rf assemble/project/artifact
mkdir -p assemble/project/artifact

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotJar \
 || . ex/util/throw 11 "Assemble \"$ARTIFACT\" error $?!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

ARTIFACT="${REPOSITORY_NAME}-${TAG}-sources.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotSource \
 || . ex/util/throw 12 "Assemble \"$ARTIFACT\" error $?!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

ARTIFACT="${REPOSITORY_NAME}-${TAG}.pom"
gradle -p "$REPOSITORY" lib:assembleSnapshotPom \
 || . ex/util/throw 12 "Assemble \"$ARTIFACT\" error $?!"
. ex/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

exit 0
